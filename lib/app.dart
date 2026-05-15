import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class RecipeRecord {
  const RecipeRecord({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
  });

  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> instructions;

  String get ingredientsPreview => ingredients.length <= 5 ? ingredients.join(', ') : '${ingredients.take(5).join(', ')}...';
  String get searchableText => '$title ${ingredients.join(' ')} ${instructions.join(' ')}';
}

class ConnectedDataset {
  const ConnectedDataset({
    required this.originalName,
    required this.localPath,
    required this.sizeBytes,
    required this.kind,
  });

  final String originalName;
  final String localPath;
  final int sizeBytes;
  final String kind;

  bool get isJsonl => kind == 'JSONL';

  String get sizeLabel {
    final mb = sizeBytes / 1024 / 1024;
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(2)} ГБ';
    return '${mb.toStringAsFixed(1)} МБ';
  }
}

class JsonlScanResult {
  const JsonlScanResult({required this.matches, required this.nextOffset, required this.reachedEnd});

  final List<RecipeRecord> matches;
  final int nextOffset;
  final bool reachedEnd;
}

class RecipeSearchApp extends StatelessWidget {
  const RecipeSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Search Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D5DF6)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      home: const RecipeHomeScreen(),
    );
  }
}

class RecipeHomeScreen extends StatefulWidget {
  const RecipeHomeScreen({super.key});

  @override
  State<RecipeHomeScreen> createState() => _RecipeHomeScreenState();
}

class _RecipeHomeScreenState extends State<RecipeHomeScreen> {
  static const int pageSize = 10;

  final queryController = TextEditingController(text: 'рис');
  final includeController = TextEditingController();
  final excludeController = TextEditingController();
  final scrollController = ScrollController();
  final includeIngredients = <String>['рис'];
  final excludeIngredients = <String>['орехи'];
  final shownRecipes = <RecipeRecord>[];
  final enabledDatasetPaths = <String>{};
  final jsonlOffsets = <String, int>{};

  List<ConnectedDataset> availableDatasets = <ConnectedDataset>[];
  RecipeRecord? selectedRecipe;
  String datasetStatus = 'loading';
  String? datasetError;
  double copyProgress = 0;
  int activeDatasetIndex = 0;
  bool jsonlEndReached = false;
  bool searchRunning = false;
  bool libraryLoaded = false;
  bool manageDatasets = false;

  List<ConnectedDataset> get enabledDatasets => availableDatasets.where((dataset) => enabledDatasetPaths.contains(dataset.localPath)).toList();
  bool get datasetReady => enabledDatasets.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _restoreDatasetLibrary();
  }

  @override
  void dispose() {
    queryController.dispose();
    includeController.dispose();
    excludeController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  bool _goBackOneStep() {
    if (selectedRecipe != null) {
      setState(() => selectedRecipe = null);
      return true;
    }
    if (manageDatasets && datasetReady) {
      setState(() => manageDatasets = false);
      _restartSearch();
      return true;
    }
    return false;
  }

  void _handleSystemBack() {
    if (_goBackOneStep()) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Вы уже на главном экране. Чтобы свернуть приложение, используйте кнопку Домой.')),
    );
  }

  Future<Directory> _datasetsDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/datasets');
    await dir.create(recursive: true);
    return dir;
  }

  Future<File> _libraryConfigFile() async {
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/dataset_library.json');
  }

  Future<void> _restoreDatasetLibrary() async {
    setState(() {
      datasetStatus = 'loading';
      datasetError = null;
    });

    try {
      final datasets = await _scanStoredDatasets();
      final config = await _libraryConfigFile();
      final savedEnabledPaths = <String>{};

      if (await config.exists()) {
        final raw = jsonDecode(await config.readAsString(encoding: utf8));
        if (raw is Map<String, dynamic>) {
          final enabled = raw['enabledDatasetPaths'];
          if (enabled is List) savedEnabledPaths.addAll(enabled.map((item) => item.toString()));
        }
      }

      final existingPaths = datasets.map((dataset) => dataset.localPath).toSet();
      savedEnabledPaths.removeWhere((path) => !existingPaths.contains(path));
      if (savedEnabledPaths.isEmpty && datasets.length == 1) savedEnabledPaths.add(datasets.first.localPath);

      setState(() {
        availableDatasets = datasets;
        enabledDatasetPaths
          ..clear()
          ..addAll(savedEnabledPaths);
        datasetStatus = 'ready';
        libraryLoaded = true;
        manageDatasets = enabledDatasetPaths.isEmpty;
      });

      await _saveDatasetLibraryConfig();
      if (enabledDatasetPaths.isNotEmpty) await _restartSearch();
    } catch (error) {
      setState(() {
        datasetStatus = 'error';
        datasetError = error.toString();
        libraryLoaded = true;
        manageDatasets = true;
      });
    }
  }

  Future<List<ConnectedDataset>> _scanStoredDatasets() async {
    final dir = await _datasetsDirectory();
    final files = await dir
        .list()
        .where((entity) => entity is File && _isSupportedDatasetFile(entity.path))
        .cast<File>()
        .toList();
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    final datasets = <ConnectedDataset>[];
    for (final file in files) {
      final name = file.path.split(Platform.pathSeparator).last;
      datasets.add(ConnectedDataset(originalName: name, localPath: file.path, sizeBytes: await file.length(), kind: _datasetKind(name)));
    }
    return datasets;
  }

  Future<void> _saveDatasetLibraryConfig() async {
    final config = await _libraryConfigFile();
    await config.writeAsString(jsonEncode({'enabledDatasetPaths': enabledDatasetPaths.toList()}), encoding: utf8, flush: true);
  }

  Future<void> _refreshStoredDatasets() async {
    final datasets = await _scanStoredDatasets();
    final existingPaths = datasets.map((dataset) => dataset.localPath).toSet();
    setState(() {
      availableDatasets = datasets;
      enabledDatasetPaths.removeWhere((path) => !existingPaths.contains(path));
    });
    await _saveDatasetLibraryConfig();
  }

  Future<void> _pickAndCopyDataset() async {
    setState(() {
      datasetStatus = 'picking';
      datasetError = null;
      copyProgress = 0;
    });

    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any, withData: false);
      if (result == null || result.files.isEmpty) {
        setState(() => datasetStatus = 'ready');
        return;
      }

      final picked = result.files.single;
      final sourcePath = picked.path;
      final displayName = picked.name.isEmpty ? sourcePath?.split(Platform.pathSeparator).last ?? 'recipes_dataset' : picked.name;

      if (!_isSupportedDatasetFile(displayName) && (sourcePath == null || !_isSupportedDatasetFile(sourcePath))) {
        throw const FileSystemException('Выберите файл .jsonl, .sqlite, .sqlite3 или .db.');
      }
      if (sourcePath == null) {
        throw const FileSystemException('Система не дала прямой путь к файлу. Для этого источника понадобится отдельный SAF/URI-режим.');
      }

      final source = File(sourcePath);
      final total = await source.length();
      final datasetsDir = await _datasetsDirectory();
      final destination = File('${datasetsDir.path}/${_safeFileName(displayName)}');
      final sink = destination.openWrite();
      var copied = 0;

      setState(() => datasetStatus = 'copying');
      await for (final chunk in source.openRead()) {
        copied += chunk.length;
        sink.add(chunk);
        if (total > 0 && mounted) setState(() => copyProgress = copied / total);
      }
      await sink.close();

      await _refreshStoredDatasets();
      setState(() {
        enabledDatasetPaths.add(destination.path);
        datasetStatus = 'ready';
        copyProgress = 1;
        manageDatasets = false;
      });
      await _saveDatasetLibraryConfig();
      await _restartSearch();
    } catch (error) {
      setState(() {
        datasetStatus = 'error';
        datasetError = error.toString();
      });
    }
  }

  Future<void> _toggleDataset(ConnectedDataset dataset, bool enabled) async {
    setState(() {
      if (enabled) {
        enabledDatasetPaths.add(dataset.localPath);
      } else {
        enabledDatasetPaths.remove(dataset.localPath);
      }
      manageDatasets = enabledDatasetPaths.isEmpty;
    });
    await _saveDatasetLibraryConfig();
    await _restartSearch();
  }

  Future<void> _restartSearch() async {
    setState(() {
      shownRecipes.clear();
      jsonlOffsets.clear();
      activeDatasetIndex = 0;
      jsonlEndReached = enabledDatasets.isEmpty;
    });
    if (enabledDatasets.isNotEmpty) await _loadMoreResults(reset: true);
  }

  Future<void> _loadMoreResults({bool reset = false}) async {
    if (searchRunning) return;
    if (enabledDatasets.isEmpty) {
      setState(() => jsonlEndReached = true);
      return;
    }

    setState(() => searchRunning = true);

    try {
      final matches = <RecipeRecord>[];
      final datasets = enabledDatasets;
      var datasetIndex = reset ? 0 : activeDatasetIndex;
      if (reset) jsonlOffsets.clear();

      while (matches.length < pageSize && datasetIndex < datasets.length) {
        final activeDataset = datasets[datasetIndex];
        if (!activeDataset.isJsonl) {
          datasetIndex += 1;
          continue;
        }

        final scan = await _scanJsonl(
          file: File(activeDataset.localPath),
          startOffset: jsonlOffsets[activeDataset.localPath] ?? 0,
          limit: pageSize - matches.length,
          query: queryController.text,
          include: includeIngredients,
          exclude: excludeIngredients,
        );

        matches.addAll(scan.matches);
        jsonlOffsets[activeDataset.localPath] = scan.nextOffset;
        if (scan.reachedEnd) {
          datasetIndex += 1;
        } else {
          break;
        }
      }

      setState(() {
        if (reset) shownRecipes.clear();
        shownRecipes.addAll(matches);
        activeDatasetIndex = datasetIndex;
        jsonlEndReached = datasetIndex >= datasets.length;
        datasetError = null;
      });
    } catch (error) {
      setState(() => datasetError = error.toString());
    } finally {
      if (mounted) setState(() => searchRunning = false);
    }
  }

  void _addChip(TextEditingController controller, List<String> target) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      if (!target.contains(value)) target.add(value);
      controller.clear();
    });
    _restartSearch();
  }

  void _scrollToTop() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(0, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    if (!libraryLoaded) {
      return const Scaffold(body: SafeArea(child: Center(child: CircularProgressIndicator())));
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleSystemBack();
      },
      child: Scaffold(
        floatingActionButton: datasetReady && selectedRecipe == null && !manageDatasets
            ? FloatingActionButton.small(onPressed: _scrollToTop, tooltip: 'Наверх', child: const Icon(Icons.keyboard_arrow_up_rounded))
            : null,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AppHeader(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: selectedRecipe != null
                          ? RecipeDetailView(recipe: selectedRecipe!, onBack: () => setState(() => selectedRecipe = null))
                          : manageDatasets || !datasetReady
                              ? DatasetConnectView(
                                  availableDatasets: availableDatasets,
                                  enabledDatasetPaths: enabledDatasetPaths,
                                  status: datasetStatus,
                                  progress: copyProgress,
                                  error: datasetError,
                                  canOpenSearch: datasetReady,
                                  onPickDataset: _pickAndCopyDataset,
                                  onToggleDataset: _toggleDataset,
                                  onOpenSearch: () {
                                    setState(() => manageDatasets = false);
                                    _restartSearch();
                                  },
                                )
                              : SearchView(
                                  scrollController: scrollController,
                                  enabledDatasets: enabledDatasets,
                                  datasetError: datasetError,
                                  queryController: queryController,
                                  includeController: includeController,
                                  excludeController: excludeController,
                                  includeIngredients: includeIngredients,
                                  excludeIngredients: excludeIngredients,
                                  recipes: shownRecipes,
                                  searchRunning: searchRunning,
                                  endReached: jsonlEndReached,
                                  onQueryChanged: _restartSearch,
                                  onAddInclude: () => _addChip(includeController, includeIngredients),
                                  onAddExclude: () => _addChip(excludeController, excludeIngredients),
                                  onRemoveInclude: (item) {
                                    setState(() => includeIngredients.remove(item));
                                    _restartSearch();
                                  },
                                  onRemoveExclude: (item) {
                                    setState(() => excludeIngredients.remove(item));
                                    _restartSearch();
                                  },
                                  onLoadMore: () => _loadMoreResults(),
                                  onOpenRecipe: (recipe) => setState(() => selectedRecipe = recipe),
                                  onManageDatasets: () => setState(() => manageDatasets = true),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RECIPE SEARCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2, color: Color(0xFF6D5DF6))),
            SizedBox(height: 4),
            Text('Поиск рецептов', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          ]),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Text('RU DB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54)),
        ),
      ],
    );
  }
}

class DatasetConnectView extends StatelessWidget {
  const DatasetConnectView({
    super.key,
    required this.availableDatasets,
    required this.enabledDatasetPaths,
    required this.status,
    required this.progress,
    required this.error,
    required this.canOpenSearch,
    required this.onPickDataset,
    required this.onToggleDataset,
    required this.onOpenSearch,
  });

  final List<ConnectedDataset> availableDatasets;
  final Set<String> enabledDatasetPaths;
  final String status;
  final double progress;
  final String? error;
  final bool canOpenSearch;
  final VoidCallback onPickDataset;
  final Future<void> Function(ConnectedDataset dataset, bool enabled) onToggleDataset;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final busy = status == 'picking' || status == 'copying';
    return ListView(children: [
      _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle(
          icon: Icons.storage_rounded,
          title: 'Библиотека датасетов',
          subtitle: 'Добавляйте JSONL/SQLite-файлы один раз. Скопированные датасеты сохраняются в приложении и могут включаться в общий поиск.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF1EEFF), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFDAD2FF))),
          child: Column(children: [
            const Row(children: [
              _IconBubble(icon: Icons.upload_file_rounded),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Добавить датасет', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 3),
                Text('.jsonl, .sqlite, .sqlite3, .db', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ])),
            ]),
            const SizedBox(height: 16),
            if (busy)
              _ProgressBox(
                title: status == 'picking' ? 'Открытие выбора файла' : 'Копирование в хранилище приложения',
                value: status == 'picking' ? null : progress,
                trailing: status == 'picking' ? 'ожидание' : '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
              )
            else
              FilledButton(onPressed: onPickDataset, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: const Text('Выбрать файл датасета')),
            if (error != null) ...[const SizedBox(height: 12), _ErrorBox(message: error!)],
          ]),
        ),
        const SizedBox(height: 16),
        const Text('Доступные датасеты', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        if (availableDatasets.isEmpty)
          const _HintBox(text: 'Пока нет сохранённых датасетов. Нажмите «Выбрать файл датасета», чтобы добавить первый JSONL-файл.')
        else
          ...availableDatasets.map((dataset) => DatasetTile(dataset: dataset, enabled: enabledDatasetPaths.contains(dataset.localPath), onChanged: (value) { onToggleDataset(dataset, value); })),
        const SizedBox(height: 12),
        FilledButton(onPressed: canOpenSearch ? onOpenSearch : null, style: FilledButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: const Text('Перейти к поиску')),
      ])),
    ]);
  }
}

class DatasetTile extends StatelessWidget {
  const DatasetTile({super.key, required this.dataset, required this.enabled, required this.onChanged});

  final ConnectedDataset dataset;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Checkbox(value: enabled, onChanged: (value) => onChanged(value ?? false)),
        const SizedBox(width: 6),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dataset.originalName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text('${dataset.kind} · ${dataset.sizeLabel}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ])),
      ]),
    );
  }
}

class SearchView extends StatelessWidget {
  const SearchView({
    super.key,
    required this.scrollController,
    required this.enabledDatasets,
    required this.datasetError,
    required this.queryController,
    required this.includeController,
    required this.excludeController,
    required this.includeIngredients,
    required this.excludeIngredients,
    required this.recipes,
    required this.searchRunning,
    required this.endReached,
    required this.onQueryChanged,
    required this.onAddInclude,
    required this.onAddExclude,
    required this.onRemoveInclude,
    required this.onRemoveExclude,
    required this.onLoadMore,
    required this.onOpenRecipe,
    required this.onManageDatasets,
  });

  final ScrollController scrollController;
  final List<ConnectedDataset> enabledDatasets;
  final String? datasetError;
  final TextEditingController queryController;
  final TextEditingController includeController;
  final TextEditingController excludeController;
  final List<String> includeIngredients;
  final List<String> excludeIngredients;
  final List<RecipeRecord> recipes;
  final bool searchRunning;
  final bool endReached;
  final VoidCallback onQueryChanged;
  final VoidCallback onAddInclude;
  final VoidCallback onAddExclude;
  final ValueChanged<String> onRemoveInclude;
  final ValueChanged<String> onRemoveExclude;
  final VoidCallback onLoadMore;
  final ValueChanged<RecipeRecord> onOpenRecipe;
  final VoidCallback onManageDatasets;

  @override
  Widget build(BuildContext context) {
    final canLoadMore = !searchRunning && !endReached;
    return ListView(controller: scrollController, children: [
      _DatasetStatusPanel(enabledDatasets: enabledDatasets, onManageDatasets: onManageDatasets),
      if (datasetError != null) ...[const SizedBox(height: 12), _ErrorBox(message: datasetError!)],
      const SizedBox(height: 12),
      _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: queryController, decoration: InputDecoration(hintText: 'Название или текст рецепта', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: const Color(0xFFF4F6FB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)), onSubmitted: (_) => onQueryChanged()),
        const SizedBox(height: 10),
        FilledButton.tonal(onPressed: onQueryChanged, child: const Text('Искать заново')),
        const SizedBox(height: 16),
        _ChipEditor(title: 'Нужные ингредиенты', controller: includeController, chips: includeIngredients, tone: _ChipTone.include, onAdd: onAddInclude, onRemove: onRemoveInclude),
        const SizedBox(height: 14),
        _ChipEditor(title: 'Исключить', controller: excludeController, chips: excludeIngredients, tone: _ChipTone.exclude, onAdd: onAddExclude, onRemove: onRemoveExclude),
      ])),
      const SizedBox(height: 14),
      _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Найденные рецепты', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text('Показано ${recipes.length}. Далее добавляет вниз.', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ])),
          const SizedBox(width: 8),
          _SmallPill(label: 'по 10'),
        ]),
        const SizedBox(height: 12),
        if (recipes.isEmpty && searchRunning)
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator()))
        else if (recipes.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('Ничего не найдено. Попробуй изменить фильтры.', style: TextStyle(color: Colors.black54))))
        else
          ...recipes.map((recipe) => RecipeResultCard(recipe: recipe, onTap: () => onOpenRecipe(recipe))),
        const SizedBox(height: 10),
        FilledButton(onPressed: canLoadMore ? onLoadMore : null, style: FilledButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(searchRunning ? 'Поиск...' : endReached ? 'Больше результатов нет' : 'Далее: показать ещё 10')),
      ])),
    ]);
  }
}

class RecipeDetailView extends StatelessWidget {
  const RecipeDetailView({super.key, required this.recipe, required this.onBack});
  final RecipeRecord recipe;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      _Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        OutlinedButton.icon(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded), label: const Text('Назад к результатам')),
        const SizedBox(height: 14),
        Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF1D1B2F), borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Рецепт · ${recipe.id}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 8),
          Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1)),
        ])),
        const SizedBox(height: 18),
        const _SectionTitle(icon: Icons.list_alt_rounded, title: 'Ингредиенты', subtitle: 'Список из подключённого датасета.'),
        const SizedBox(height: 10),
        ...recipe.ingredients.map((ingredient) => _ListLine(text: ingredient)),
        const SizedBox(height: 10),
        const _SectionTitle(icon: Icons.menu_book_rounded, title: 'Приготовление', subtitle: 'Шаги автоматически нумеруются.'),
        const SizedBox(height: 10),
        ...recipe.instructions.asMap().entries.map((entry) => _StepLine(index: entry.key + 1, text: entry.value)),
      ])),
    ]);
  }
}

class RecipeResultCard extends StatelessWidget {
  const RecipeResultCard({super.key, required this.recipe, required this.onTap});
  final RecipeRecord recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 10), child: InkWell(borderRadius: BorderRadius.circular(24), onTap: onTap, child: Padding(padding: const EdgeInsets.all(14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _IconBubble(icon: Icons.restaurant_menu_rounded),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(recipe.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(recipe.ingredientsPreview, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.35)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6, children: recipe.ingredients.take(3).map((item) => _FilterChip(label: item, tone: _ChipTone.neutral)).toList()),
      ])),
      const SizedBox(width: 4),
      const Icon(Icons.chevron_right_rounded, color: Colors.black38),
    ]))));
  }
}

class _DatasetStatusPanel extends StatelessWidget {
  const _DatasetStatusPanel({required this.enabledDatasets, required this.onManageDatasets});
  final List<ConnectedDataset> enabledDatasets;
  final VoidCallback onManageDatasets;

  @override
  Widget build(BuildContext context) {
    final title = enabledDatasets.length == 1 ? enabledDatasets.first.originalName : 'Включено датасетов: ${enabledDatasets.length}';
    final subtitle = enabledDatasets.length == 1 ? '${enabledDatasets.first.kind} · ${enabledDatasets.first.sizeLabel}' : enabledDatasets.map((dataset) => dataset.originalName).join(', ');
    return _Panel(child: Row(children: [
      const _IconBubble(icon: Icons.folder_copy_rounded),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ])),
      TextButton(onPressed: onManageDatasets, child: const Text('датасеты')),
    ]));
  }
}

class _ChipEditor extends StatelessWidget {
  const _ChipEditor({required this.title, required this.controller, required this.chips, required this.tone, required this.onAdd, required this.onRemove});
  final String title;
  final TextEditingController controller;
  final List<String> chips;
  final _ChipTone tone;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, letterSpacing: 0.8, color: Colors.black54, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: TextField(controller: controller, decoration: InputDecoration(isDense: true, hintText: 'добавить ингредиент', filled: true, fillColor: const Color(0xFFF4F6FB), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), onSubmitted: (_) => onAdd())),
        const SizedBox(width: 8),
        IconButton.filledTonal(onPressed: onAdd, icon: const Icon(Icons.add_rounded)),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: chips.map((item) => _FilterChip(label: item, tone: tone, onRemove: () => onRemove(item))).toList()),
    ]);
  }
}

enum _ChipTone { neutral, include, exclude }

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.tone, this.onRemove});
  final String label;
  final _ChipTone tone;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      _ChipTone.include => (bg: const Color(0xFFEAF8EF), fg: const Color(0xFF166534)),
      _ChipTone.exclude => (bg: const Color(0xFFFFEBEE), fg: const Color(0xFFB91C1C)),
      _ChipTone.neutral => (bg: const Color(0xFFF1F5F9), fg: const Color(0xFF475569)),
    };
    final maxWidth = (MediaQuery.sizeOf(context).width * 0.62).clamp(120.0, 260.0).toDouble();
    return ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [
      Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: colors.fg, fontWeight: FontWeight.w700))),
      if (onRemove != null) ...[const SizedBox(width: 4), InkWell(onTap: onRemove, child: Icon(Icons.close_rounded, size: 14, color: colors.fg))],
    ])));
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 18, offset: Offset(0, 8))]), child: child);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [_IconBubble(icon: icon), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.35))]))]);
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFEAE5FF), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: const Color(0xFF5B45F0), size: 20));
}

class _ProgressBox extends StatelessWidget {
  const _ProgressBox({required this.title, required this.value, required this.trailing});
  final String title;
  final double? value;
  final String trailing;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))), Text(trailing, style: const TextStyle(fontSize: 12, color: Colors.black54))]), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: value, minHeight: 8))]));
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFEAE5FF), borderRadius: BorderRadius.circular(999)), child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF5B45F0))));
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => _Panel(child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C), height: 1.35)));
}

class _HintBox extends StatelessWidget {
  const _HintBox({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(18)), child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.35)));
}

class _ListLine extends StatelessWidget {
  const _ListLine({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(16)), child: Text(text));
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.index, required this.text});
  final int index;
  final String text;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(16)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 14, backgroundColor: const Color(0xFFEAE5FF), foregroundColor: const Color(0xFF5B45F0), child: Text('$index', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(height: 1.35)))]));
}

Future<JsonlScanResult> _scanJsonl({required File file, required int startOffset, required int limit, required String query, required List<String> include, required List<String> exclude}) async {
  final raf = await file.open(mode: FileMode.read);
  final matches = <RecipeRecord>[];
  final pending = <int>[];
  var offset = startOffset;
  var reachedEnd = false;
  try {
    await raf.setPosition(startOffset);
    while (matches.length < limit) {
      final chunk = await raf.read(64 * 1024);
      if (chunk.isEmpty) {
        if (pending.isNotEmpty) {
          final recipe = _recipeFromLineBytes(pending);
          if (recipe != null && _matchesFilters(recipe, query, include, exclude)) matches.add(recipe);
        }
        reachedEnd = true;
        break;
      }
      for (final byte in chunk) {
        offset += 1;
        if (byte == 10) {
          final recipe = _recipeFromLineBytes(pending);
          if (recipe != null && _matchesFilters(recipe, query, include, exclude)) {
            matches.add(recipe);
            if (matches.length >= limit) break;
          }
          pending.clear();
        } else {
          pending.add(byte);
        }
      }
    }
  } finally {
    await raf.close();
  }
  return JsonlScanResult(matches: matches, nextOffset: offset, reachedEnd: reachedEnd);
}

RecipeRecord? _recipeFromLineBytes(List<int> bytes) {
  if (bytes.isEmpty) return null;
  var lineBytes = bytes;
  if (lineBytes.isNotEmpty && lineBytes.last == 13) lineBytes = lineBytes.sublist(0, lineBytes.length - 1);
  final line = utf8.decode(lineBytes, allowMalformed: true).trim();
  if (line.isEmpty) return null;
  try {
    final obj = jsonDecode(line);
    if (obj is! Map<String, dynamic>) return null;
    return _recipeFromMap(obj);
  } catch (_) {
    return null;
  }
}

RecipeRecord _recipeFromMap(Map<String, dynamic> obj) {
  final id = _firstString(obj, ['id', 'recipe_id', 'recipe_no']) ?? 'unknown';
  final title = _firstString(obj, ['title', 'title_ru', 'name']) ?? 'Без названия';
  final ingredients = _stringList(obj['ingredients']) ?? _stringList(obj['ingredients_ru']) ?? const <String>[];
  final instructions = _stringList(obj['instructions']) ?? _stringList(obj['instructions_ru']) ?? const <String>[];
  return RecipeRecord(id: id, title: title, ingredients: ingredients, instructions: instructions);
}

String? _firstString(Map<String, dynamic> obj, List<String> keys) {
  for (final key in keys) {
    final value = obj[key];
    if (value != null) return value.toString();
  }
  return null;
}

List<String>? _stringList(dynamic value) {
  if (value == null) return null;
  if (value is List) return value.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
  if (value is String) return value.split(RegExp(r'\r?\n')).map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  return null;
}

bool _matchesFilters(RecipeRecord recipe, String query, List<String> include, List<String> exclude) {
  final queryNorm = _normalize(query);
  final allText = _normalize(recipe.searchableText);
  final ingredients = recipe.ingredients.map(_normalize).toList();
  final queryOk = queryNorm.isEmpty || allText.contains(queryNorm);
  final includeOk = include.every((item) => ingredients.any((ingredient) => ingredient.contains(_normalize(item))));
  final excludeOk = exclude.every((item) => !ingredients.any((ingredient) => ingredient.contains(_normalize(item))));
  return queryOk && includeOk && excludeOk;
}

bool _isSupportedDatasetFile(String name) {
  final lower = name.toLowerCase();
  return lower.endsWith('.jsonl') || lower.endsWith('.sqlite') || lower.endsWith('.sqlite3') || lower.endsWith('.db');
}

String _normalize(String value) => value.toLowerCase().replaceAll('ё', 'е').trim();

String _datasetKind(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.jsonl')) return 'JSONL';
  if (lower.endsWith('.sqlite') || lower.endsWith('.sqlite3') || lower.endsWith('.db')) return 'SQLite';
  return 'dataset';
}

String _safeFileName(String name) => name.replaceAll(RegExp(r'[^a-zA-Z0-9а-яА-ЯёЁ._-]+'), '_');
