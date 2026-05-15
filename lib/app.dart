import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DemoRecipe {
  const DemoRecipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
  });

  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> instructions;

  String get ingredientsPreview {
    if (ingredients.length <= 5) return ingredients.join(', ');
    return '${ingredients.take(5).join(', ')}...';
  }
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

  String get sizeLabel {
    final mb = sizeBytes / 1024 / 1024;
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(2)} ГБ';
    return '${mb.toStringAsFixed(1)} МБ';
  }
}

const demoRecipes = <DemoRecipe>[
  DemoRecipe(
    id: 'ru_demo_001',
    title: 'Куриная грудка с рисом и брокколи',
    ingredients: ['куриная грудка', 'рис', 'брокколи', 'соль', 'оливковое масло'],
    instructions: [
      'Отварите рис до мягкости.',
      'Запеките или обжарьте куриную грудку до готовности.',
      'Брокколи приготовьте на пару 5–7 минут.',
      'Соедините ингредиенты и посолите по вкусу.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_002',
    title: 'Овсянка с бананом',
    ingredients: ['овсянка', 'молоко', 'банан', 'корица'],
    instructions: ['Залейте овсянку молоком.', 'Варите до мягкости.', 'Добавьте банан и корицу.'],
  ),
  DemoRecipe(
    id: 'ru_demo_003',
    title: 'Омлет с помидором и сыром',
    ingredients: ['яйца', 'молоко', 'помидор', 'сыр', 'соль'],
    instructions: ['Взбейте яйца с молоком и солью.', 'Добавьте помидор и сыр.', 'Готовьте на слабом огне.'],
  ),
  DemoRecipe(
    id: 'ru_demo_004',
    title: 'Гречка с грибами',
    ingredients: ['гречка', 'шампиньоны', 'лук', 'сливочное масло', 'соль'],
    instructions: ['Отварите гречку.', 'Обжарьте грибы с луком.', 'Смешайте и добавьте масло.'],
  ),
  DemoRecipe(
    id: 'ru_demo_005',
    title: 'Фузилли с томатным соусом',
    ingredients: ['фузилли', 'томатный соус', 'чеснок', 'пармезан', 'орегано'],
    instructions: ['Отварите фузилли.', 'Разогрейте соус с чесноком.', 'Смешайте и посыпьте пармезаном.'],
  ),
  DemoRecipe(
    id: 'ru_demo_006',
    title: 'Салат с авокадо и красным луком',
    ingredients: ['авокадо', 'красный лук', 'помидор', 'лимонный сок', 'соль'],
    instructions: ['Нарежьте овощи.', 'Добавьте лимонный сок и соль.', 'Аккуратно перемешайте.'],
  ),
  DemoRecipe(
    id: 'ru_demo_007',
    title: 'Рис с креветками',
    ingredients: ['рис', 'креветки', 'чеснок', 'соевый соус', 'растительное масло'],
    instructions: ['Отварите рис.', 'Обжарьте креветки с чесноком.', 'Добавьте рис и соевый соус.'],
  ),
  DemoRecipe(
    id: 'ru_demo_008',
    title: 'Картофель с беконом',
    ingredients: ['картофель', 'бекон', 'лук', 'соль', 'перец'],
    instructions: ['Нарежьте картофель и лук.', 'Обжарьте бекон.', 'Добавьте картофель и готовьте.'],
  ),
  DemoRecipe(
    id: 'ru_demo_009',
    title: 'Пармезановый рис',
    ingredients: ['рис', 'пармезан', 'сливочное масло', 'соль'],
    instructions: ['Отварите рис.', 'Добавьте масло.', 'Перемешайте с пармезаном.'],
  ),
  DemoRecipe(
    id: 'ru_demo_010',
    title: 'Острый чили с фасолью',
    ingredients: ['фасоль', 'чили', 'томатный соус', 'лук', 'чеснок'],
    instructions: ['Обжарьте лук и чеснок.', 'Добавьте фасоль, соус и чили.', 'Тушите до густоты.'],
  ),
  DemoRecipe(
    id: 'ru_demo_011',
    title: 'Курица с соусом барбекю',
    ingredients: ['куриная грудка', 'соус барбекю', 'соль', 'перец'],
    instructions: ['Натрите курицу специями.', 'Смажьте соусом.', 'Запекайте до готовности.'],
  ),
  DemoRecipe(
    id: 'ru_demo_012',
    title: 'Рисовый салат с огурцом',
    ingredients: ['рис', 'огурец', 'зелень', 'лимонный сок', 'соль'],
    instructions: ['Остудите рис.', 'Добавьте огурец и зелень.', 'Заправьте лимонным соком.'],
  ),
];

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
  final queryController = TextEditingController(text: 'рис');
  final includeController = TextEditingController();
  final excludeController = TextEditingController();
  final includeIngredients = <String>['рис'];
  final excludeIngredients = <String>['орехи'];

  ConnectedDataset? dataset;
  DemoRecipe? selectedRecipe;
  double copyProgress = 0;
  String datasetStatus = 'empty';
  String? datasetError;
  int visibleCount = 10;

  @override
  void dispose() {
    queryController.dispose();
    includeController.dispose();
    excludeController.dispose();
    super.dispose();
  }

  bool get datasetReady => dataset != null || datasetStatus == 'demo';

  List<DemoRecipe> get filteredRecipes {
    final query = _normalize(queryController.text);
    return demoRecipes.where((recipe) {
      final ingredients = recipe.ingredients.map(_normalize).toList();
      final allText = _normalize('${recipe.title} ${recipe.ingredients.join(' ')} ${recipe.instructions.join(' ')}');
      final queryOk = query.isEmpty || allText.contains(query);
      final includeOk = includeIngredients.every((item) => ingredients.any((ingredient) => ingredient.contains(_normalize(item))));
      final excludeOk = excludeIngredients.every((item) => !ingredients.any((ingredient) => ingredient.contains(_normalize(item))));
      return queryOk && includeOk && excludeOk;
    }).toList();
  }

  List<DemoRecipe> get visibleRecipes => filteredRecipes.take(visibleCount).toList();

  void _resetVisibleResults() => setState(() => visibleCount = 10);

  void _addChip(TextEditingController controller, List<String> target) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      if (!target.contains(value)) target.add(value);
      visibleCount = 10;
      controller.clear();
    });
  }

  Future<void> _pickAndCopyDataset() async {
    setState(() {
      datasetStatus = 'picking';
      datasetError = null;
      copyProgress = 0;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jsonl', 'sqlite', 'sqlite3', 'db'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => datasetStatus = dataset == null ? 'empty' : 'ready');
        return;
      }

      final picked = result.files.single;
      final sourcePath = picked.path;
      if (sourcePath == null) {
        throw const FileSystemException('Система не дала прямой путь к файлу. Попробуем SAF/URI-режим позже.');
      }

      final source = File(sourcePath);
      final total = await source.length();
      final docs = await getApplicationDocumentsDirectory();
      final datasetsDir = Directory('${docs.path}/datasets');
      await datasetsDir.create(recursive: true);

      final safeName = _safeFileName(picked.name.isEmpty ? 'recipes_dataset' : picked.name);
      final destination = File('${datasetsDir.path}/$safeName');
      final sink = destination.openWrite();
      var copied = 0;

      setState(() => datasetStatus = 'copying');
      await for (final chunk in source.openRead()) {
        copied += chunk.length;
        sink.add(chunk);
        if (total > 0) {
          setState(() => copyProgress = copied / total);
        }
      }
      await sink.close();

      setState(() {
        dataset = ConnectedDataset(
          originalName: picked.name,
          localPath: destination.path,
          sizeBytes: total,
          kind: _datasetKind(picked.name),
        );
        datasetStatus = 'ready';
        copyProgress = 1;
        visibleCount = 10;
      });
    } catch (error) {
      setState(() {
        datasetStatus = 'error';
        datasetError = error.toString();
      });
    }
  }

  void _useDemoDataset() {
    setState(() {
      datasetStatus = 'demo';
      datasetError = null;
      visibleCount = 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        ? RecipeDetailView(
                            recipe: selectedRecipe!,
                            onBack: () => setState(() => selectedRecipe = null),
                          )
                        : datasetReady
                            ? SearchView(
                                dataset: dataset,
                                datasetStatus: datasetStatus,
                                queryController: queryController,
                                includeController: includeController,
                                excludeController: excludeController,
                                includeIngredients: includeIngredients,
                                excludeIngredients: excludeIngredients,
                                recipes: visibleRecipes,
                                totalMatches: filteredRecipes.length,
                                visibleCount: visibleCount,
                                onQueryChanged: _resetVisibleResults,
                                onAddInclude: () => _addChip(includeController, includeIngredients),
                                onAddExclude: () => _addChip(excludeController, excludeIngredients),
                                onRemoveInclude: (item) => setState(() {
                                  includeIngredients.remove(item);
                                  visibleCount = 10;
                                }),
                                onRemoveExclude: (item) => setState(() {
                                  excludeIngredients.remove(item);
                                  visibleCount = 10;
                                }),
                                onLoadMore: () => setState(() => visibleCount += 10),
                                onOpenRecipe: (recipe) => setState(() => selectedRecipe = recipe),
                                onChangeDataset: () => setState(() {
                                  dataset = null;
                                  datasetStatus = 'empty';
                                }),
                              )
                            : DatasetConnectView(
                                status: datasetStatus,
                                progress: copyProgress,
                                error: datasetError,
                                onPickDataset: _pickAndCopyDataset,
                                onUseDemo: _useDemoDataset,
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DatasetConnectView extends StatelessWidget {
  const DatasetConnectView({
    super.key,
    required this.status,
    required this.progress,
    required this.error,
    required this.onPickDataset,
    required this.onUseDemo,
  });

  final String status;
  final double progress;
  final String? error;
  final VoidCallback onPickDataset;
  final VoidCallback onUseDemo;

  @override
  Widget build(BuildContext context) {
    final isBusy = status == 'picking' || status == 'copying';
    return ListView(
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.storage_rounded,
                title: 'База рецептов',
                subtitle: 'Выберите JSONL/SQLite. Файл будет скопирован в хранилище приложения; позже здесь появится фоновый индекс для быстрого поиска.',
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EEFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFDAD2FF)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        _IconBubble(icon: Icons.upload_file_rounded),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Подключить датасет', style: TextStyle(fontWeight: FontWeight.w800)),
                              SizedBox(height: 3),
                              Text('.jsonl, .sqlite, .sqlite3, .db', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isBusy)
                      _ProgressBox(
                        title: status == 'picking' ? 'Открытие выбора файла' : 'Копирование в хранилище приложения',
                        value: status == 'picking' ? null : progress,
                        trailing: status == 'picking' ? 'ожидание' : '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      )
                    else ...[
                      FilledButton(
                        onPressed: onPickDataset,
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        child: const Text('Выбрать файл датасета'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: onUseDemo,
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        child: const Text('Открыть demo-датасет'),
                      ),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBox(message: error!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: _StatTile(value: '10+', label: 'догрузка')),
                  SizedBox(width: 8),
                  Expanded(child: _StatTile(value: 'JSONL', label: 'построчно')),
                  SizedBox(width: 8),
                  Expanded(child: _StatTile(value: 'SQLite', label: 'индекс')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchView extends StatelessWidget {
  const SearchView({
    super.key,
    required this.dataset,
    required this.datasetStatus,
    required this.queryController,
    required this.includeController,
    required this.excludeController,
    required this.includeIngredients,
    required this.excludeIngredients,
    required this.recipes,
    required this.totalMatches,
    required this.visibleCount,
    required this.onQueryChanged,
    required this.onAddInclude,
    required this.onAddExclude,
    required this.onRemoveInclude,
    required this.onRemoveExclude,
    required this.onLoadMore,
    required this.onOpenRecipe,
    required this.onChangeDataset,
  });

  final ConnectedDataset? dataset;
  final String datasetStatus;
  final TextEditingController queryController;
  final TextEditingController includeController;
  final TextEditingController excludeController;
  final List<String> includeIngredients;
  final List<String> excludeIngredients;
  final List<DemoRecipe> recipes;
  final int totalMatches;
  final int visibleCount;
  final VoidCallback onQueryChanged;
  final VoidCallback onAddInclude;
  final VoidCallback onAddExclude;
  final ValueChanged<String> onRemoveInclude;
  final ValueChanged<String> onRemoveExclude;
  final VoidCallback onLoadMore;
  final ValueChanged<DemoRecipe> onOpenRecipe;
  final VoidCallback onChangeDataset;

  @override
  Widget build(BuildContext context) {
    final canLoadMore = recipes.length < totalMatches;
    return ListView(
      children: [
        _DatasetStatusPanel(dataset: dataset, datasetStatus: datasetStatus, onChangeDataset: onChangeDataset),
        const SizedBox(height: 12),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: queryController,
                decoration: InputDecoration(
                  hintText: 'Название или текст рецепта',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF4F6FB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                ),
                onChanged: (_) => onQueryChanged(),
              ),
              const SizedBox(height: 16),
              _ChipEditor(
                title: 'Нужные ингредиенты',
                controller: includeController,
                chips: includeIngredients,
                tone: _ChipTone.include,
                onAdd: onAddInclude,
                onRemove: onRemoveInclude,
              ),
              const SizedBox(height: 14),
              _ChipEditor(
                title: 'Исключить',
                controller: excludeController,
                chips: excludeIngredients,
                tone: _ChipTone.exclude,
                onAdd: onAddExclude,
                onRemove: onRemoveExclude,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Найденные рецепты', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('Показано ${recipes.length} из $totalMatches. Далее добавляет вниз.', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                  _SmallPill(label: 'по 10'),
                ],
              ),
              const SizedBox(height: 12),
              if (recipes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Ничего не найдено. Попробуй убрать фильтр.', style: TextStyle(color: Colors.black54))),
                )
              else
                ...recipes.map((recipe) => RecipeResultCard(recipe: recipe, onTap: () => onOpenRecipe(recipe))),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: canLoadMore ? onLoadMore : null,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(canLoadMore ? 'Далее: показать ещё 10' : 'Больше результатов нет'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RecipeDetailView extends StatelessWidget {
  const RecipeDetailView({super.key, required this.recipe, required this.onBack});

  final DemoRecipe recipe;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded), label: const Text('Назад к результатам')),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFF1D1B2F), borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Рецепт · ${recipe.id}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const _SectionTitle(icon: Icons.list_alt_rounded, title: 'Ингредиенты', subtitle: 'Список из подключённого датасета.'),
              const SizedBox(height: 10),
              ...recipe.ingredients.map((ingredient) => _ListLine(text: ingredient)),
              const SizedBox(height: 10),
              const _SectionTitle(icon: Icons.menu_book_rounded, title: 'Приготовление', subtitle: 'Шаги автоматически нумеруются.'),
              const SizedBox(height: 10),
              ...recipe.instructions.asMap().entries.map((entry) => _StepLine(index: entry.key + 1, text: entry.value)),
            ],
          ),
        ),
      ],
    );
  }
}

class RecipeResultCard extends StatelessWidget {
  const RecipeResultCard({super.key, required this.recipe, required this.onTap});

  final DemoRecipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconBubble(icon: Icons.restaurant_menu_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(recipe.ingredientsPreview, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.35)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: recipe.ingredients.take(3).map((item) => _FilterChip(label: item, tone: _ChipTone.neutral)).toList()),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatasetStatusPanel extends StatelessWidget {
  const _DatasetStatusPanel({required this.dataset, required this.datasetStatus, required this.onChangeDataset});

  final ConnectedDataset? dataset;
  final String datasetStatus;
  final VoidCallback onChangeDataset;

  @override
  Widget build(BuildContext context) {
    final title = dataset?.originalName ?? 'Demo-датасет';
    final subtitle = dataset == null ? '12 встроенных рецептов для проверки интерфейса' : '${dataset!.kind} · ${dataset!.sizeLabel} · скопирован в приложение';
    return _Panel(
      child: Row(
        children: [
          const _IconBubble(icon: Icons.folder_copy_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),
          TextButton(onPressed: onChangeDataset, child: const Text('сменить')),
        ],
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, letterSpacing: 0.8, color: Colors.black54, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'добавить ингредиент',
                  filled: true,
                  fillColor: const Color(0xFFF4F6FB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(onPressed: onAdd, icon: const Icon(Icons.add_rounded)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips.map((item) => _FilterChip(label: item, tone: tone, onRemove: () => onRemove(item))).toList()),
      ],
    );
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: colors.bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: TextStyle(fontSize: 12, color: colors.fg, fontWeight: FontWeight.w700)),
        if (onRemove != null) ...[const SizedBox(width: 4), InkWell(onTap: onRemove, child: Icon(Icons.close_rounded, size: 14, color: colors.fg))],
      ]),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 18, offset: Offset(0, 8))]),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _IconBubble(icon: icon),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.35)),
      ])),
    ]);
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFEAE5FF), borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: const Color(0xFF5B45F0), size: 20),
    );
  }
}

class _ProgressBox extends StatelessWidget {
  const _ProgressBox({required this.title, required this.value, required this.trailing});
  final String title;
  final double? value;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text(trailing, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: value, minHeight: 8)),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ]),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFEAE5FF), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF5B45F0))),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(18)),
      child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C), height: 1.35)),
    );
  }
}

class _ListLine extends StatelessWidget {
  const _ListLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(16)),
      child: Text(text),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.index, required this.text});
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 14, backgroundColor: const Color(0xFFEAE5FF), foregroundColor: const Color(0xFF5B45F0), child: Text('$index', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
      ]),
    );
  }
}

String _normalize(String value) => value.toLowerCase().replaceAll('ё', 'е').trim();

String _datasetKind(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.jsonl')) return 'JSONL';
  if (lower.endsWith('.sqlite') || lower.endsWith('.sqlite3') || lower.endsWith('.db')) return 'SQLite';
  return 'dataset';
}

String _safeFileName(String name) {
  return name.replaceAll(RegExp(r'[^a-zA-Z0-9а-яА-ЯёЁ._-]+'), '_');
}
