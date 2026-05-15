import 'package:flutter/material.dart';

void main() {
  runApp(const RecipeSearchApp());
}

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
    if (ingredients.length <= 5) {
      return ingredients.join(', ');
    }
    return '${ingredients.take(5).join(', ')}...';
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
    instructions: [
      'Залейте овсянку молоком.',
      'Варите до мягкости.',
      'Добавьте нарезанный банан и корицу.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_003',
    title: 'Омлет с помидором и сыром',
    ingredients: ['яйца', 'молоко', 'помидор', 'сыр', 'соль'],
    instructions: [
      'Взбейте яйца с молоком и солью.',
      'Добавьте нарезанный помидор и сыр.',
      'Готовьте на слабом огне до плотности.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_004',
    title: 'Гречка с грибами',
    ingredients: ['гречка', 'шампиньоны', 'лук', 'сливочное масло', 'соль'],
    instructions: [
      'Отварите гречку.',
      'Обжарьте грибы с луком.',
      'Смешайте с гречкой и добавьте сливочное масло.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_005',
    title: 'Фузилли с томатным соусом',
    ingredients: ['фузилли', 'томатный соус', 'чеснок', 'пармезан', 'орегано'],
    instructions: [
      'Отварите фузилли до состояния al dente.',
      'Разогрейте томатный соус с чесноком.',
      'Смешайте пасту с соусом и посыпьте пармезаном.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_006',
    title: 'Салат с авокадо и красным луком',
    ingredients: ['авокадо', 'красный лук', 'помидор', 'лимонный сок', 'соль'],
    instructions: [
      'Нарежьте авокадо, помидор и красный лук.',
      'Добавьте лимонный сок и соль.',
      'Аккуратно перемешайте.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_007',
    title: 'Рис с креветками',
    ingredients: ['рис', 'креветки', 'чеснок', 'соевый соус', 'растительное масло'],
    instructions: [
      'Отварите рис.',
      'Обжарьте креветки с чесноком.',
      'Добавьте рис и немного соевого соуса.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_008',
    title: 'Картофель с беконом',
    ingredients: ['картофель', 'бекон', 'лук', 'соль', 'перец'],
    instructions: [
      'Нарежьте картофель и лук.',
      'Обжарьте бекон.',
      'Добавьте картофель и готовьте до мягкости.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_009',
    title: 'Пармезановый рис',
    ingredients: ['рис', 'пармезан', 'сливочное масло', 'соль'],
    instructions: [
      'Отварите рис.',
      'Добавьте сливочное масло.',
      'Перемешайте с пармезаном.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_010',
    title: 'Острый чили с фасолью',
    ingredients: ['фасоль', 'чили', 'томатный соус', 'лук', 'чеснок'],
    instructions: [
      'Обжарьте лук и чеснок.',
      'Добавьте фасоль, томатный соус и чили.',
      'Тушите до густоты.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_011',
    title: 'Курица с соусом барбекю',
    ingredients: ['куриная грудка', 'соус барбекю', 'соль', 'перец'],
    instructions: [
      'Натрите курицу солью и перцем.',
      'Смажьте соусом барбекю.',
      'Запекайте до готовности.',
    ],
  ),
  DemoRecipe(
    id: 'ru_demo_012',
    title: 'Рисовый салат с огурцом',
    ingredients: ['рис', 'огурец', 'зелень', 'лимонный сок', 'соль'],
    instructions: [
      'Остудите отваренный рис.',
      'Добавьте огурец и зелень.',
      'Заправьте лимонным соком.',
    ],
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
        cardTheme: CardTheme(
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
  bool datasetReady = false;
  DemoRecipe? selectedRecipe;

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
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: selectedRecipe != null
                          ? RecipeDetailView(
                              key: ValueKey(selectedRecipe!.id),
                              recipe: selectedRecipe!,
                              onBack: () => setState(() => selectedRecipe = null),
                            )
                          : datasetReady
                              ? SearchView(
                                  key: const ValueKey('search'),
                                  recipes: demoRecipes,
                                  onOpenRecipe: (recipe) => setState(() => selectedRecipe = recipe),
                                )
                              : DatasetConnectView(
                                  key: const ValueKey('dataset'),
                                  onReady: () => setState(() => datasetReady = true),
                                ),
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

class _AppHeader extends StatelessWidget {
  const _AppHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECIPE SEARCH',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2, color: Color(0xFF6D5DF6)),
            ),
            SizedBox(height: 4),
            Text('Поиск рецептов', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Text('RU DB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54)),
        ),
      ],
    );
  }
}

class DatasetConnectView extends StatefulWidget {
  const DatasetConnectView({super.key, required this.onReady});

  final VoidCallback onReady;

  @override
  State<DatasetConnectView> createState() => _DatasetConnectViewState();
}

class _DatasetConnectViewState extends State<DatasetConnectView> {
  int step = 0;

  Future<void> _simulateDatasetConnect() async {
    setState(() => step = 1);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    setState(() => step = 2);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    setState(() => step = 3);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.storage_rounded,
                title: 'База рецептов',
                subtitle: 'Сначала приложение будет копировать выбранный JSONL/SQLite в своё хранилище. Затем первые результаты можно показывать построчно, а быстрый индекс строить в фоне.',
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
                              Text('recipes_ru_base.jsonl', style: TextStyle(fontWeight: FontWeight.w800)),
                              SizedBox(height: 3),
                              Text('≈ 2 ГБ · Recipe1M RU layer', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (step == 0)
                      FilledButton(
                        onPressed: _simulateDatasetConnect,
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        child: const Text('Выбрать и подключить датасет'),
                      ),
                    if (step == 1) const _ProgressBox(title: 'Копирование файла', value: 0.42, trailing: '42%'),
                    if (step == 2) const _ProgressBox(title: 'Первые результаты уже доступны', value: 0.71, trailing: 'индекс строится'),
                    if (step == 3) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFE9F8EF), borderRadius: BorderRadius.circular(18)),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF15803D)),
                            SizedBox(width: 8),
                            Expanded(child: Text('Demo-датасет подключён. 12 рецептов.', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF166534)))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: widget.onReady,
                        style: FilledButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        child: const Text('Перейти к поиску'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: _StatTile(value: '10', label: 'за раз')),
                  SizedBox(width: 8),
                  Expanded(child: _StatTile(value: 'JSONL', label: 'построчно')),
                  SizedBox(width: 8),
                  Expanded(child: _StatTile(value: 'SQLite', label: 'быстро')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.recipes, required this.onOpenRecipe});

  final List<DemoRecipe> recipes;
  final ValueChanged<DemoRecipe> onOpenRecipe;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final queryController = TextEditingController(text: 'рис');
  final includeController = TextEditingController();
  final excludeController = TextEditingController();
  final includeIngredients = <String>['рис'];
  final excludeIngredients = <String>['орехи'];
  int page = 0;
  static const pageSize = 10;

  @override
  void dispose() {
    queryController.dispose();
    includeController.dispose();
    excludeController.dispose();
    super.dispose();
  }

  List<DemoRecipe> get _filteredRecipes {
    final query = _normalize(queryController.text);
    return widget.recipes.where((recipe) {
      final title = _normalize(recipe.title);
      final ingredients = recipe.ingredients.map(_normalize).toList();
      final allText = _normalize('${recipe.title} ${recipe.ingredients.join(' ')} ${recipe.instructions.join(' ')}');

      final queryOk = query.isEmpty || allText.contains(query) || title.contains(query);
      final includeOk = includeIngredients.every((item) => ingredients.any((ingredient) => ingredient.contains(_normalize(item))));
      final excludeOk = excludeIngredients.every((item) => !ingredients.any((ingredient) => ingredient.contains(_normalize(item))));
      return queryOk && includeOk && excludeOk;
    }).toList();
  }

  List<DemoRecipe> get _pageItems {
    final filtered = _filteredRecipes;
    final start = page * pageSize;
    if (start >= filtered.length) return [];
    final end = (start + pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  void _addChip(TextEditingController controller, List<String> target) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    if (!target.contains(value)) {
      setState(() {
        target.add(value);
        page = 0;
      });
    }
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecipes;
    final items = _pageItems;
    final hasNext = (page + 1) * pageSize < filtered.length;

    return ListView(
      children: [
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
                onChanged: (_) => setState(() => page = 0),
              ),
              const SizedBox(height: 16),
              _ChipEditor(
                title: 'Нужные ингредиенты',
                controller: includeController,
                chips: includeIngredients,
                tone: _ChipTone.include,
                onAdd: () => _addChip(includeController, includeIngredients),
                onRemove: (item) => setState(() {
                  includeIngredients.remove(item);
                  page = 0;
                }),
              ),
              const SizedBox(height: 14),
              _ChipEditor(
                title: 'Исключить',
                controller: excludeController,
                chips: excludeIngredients,
                tone: _ChipTone.exclude,
                onAdd: () => _addChip(excludeController, excludeIngredients),
                onRemove: (item) => setState(() {
                  excludeIngredients.remove(item);
                  page = 0;
                }),
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
                      Text('Показано ${items.length} из ${filtered.length}. Страница ${page + 1}.', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                  _SmallPill(label: 'по 10'),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Ничего не найдено. Попробуй убрать фильтр.', style: TextStyle(color: Colors.black54))),
                )
              else
                ...items.map((recipe) => RecipeResultCard(recipe: recipe, onTap: () => widget.onOpenRecipe(recipe))),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: page == 0 ? null : () => setState(() => page -= 1),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Назад'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: hasNext ? () => setState(() => page += 1) : null,
                      style: FilledButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Далее'),
                    ),
                  ),
                ],
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
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Назад к результатам'),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1B2F),
                  borderRadius: BorderRadius.circular(24),
                ),
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
              ...recipe.ingredients.map((ingredient) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(16)),
                    child: Text(ingredient),
                  )),
              const SizedBox(height: 10),
              const _SectionTitle(icon: Icons.menu_book_rounded, title: 'Приготовление', subtitle: 'Шаги автоматически нумеруются.'),
              const SizedBox(height: 10),
              ...recipe.instructions.asMap().entries.map((entry) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF4F6FB), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 14, backgroundColor: const Color(0xFFEAE5FF), foregroundColor: const Color(0xFF5B45F0), child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
                        const SizedBox(width: 10),
                        Expanded(child: Text(entry.value, style: const TextStyle(height: 1.35))),
                      ],
                    ),
                  )),
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
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: recipe.ingredients.take(3).map((item) => _FilterChip(label: item, tone: _ChipTone.neutral)).toList(),
                    ),
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

class _ChipEditor extends StatelessWidget {
  const _ChipEditor({
    required this.title,
    required this.controller,
    required this.chips,
    required this.tone,
    required this.onAdd,
    required this.onRemove,
  });

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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((item) => _FilterChip(label: item, tone: tone, onRemove: () => onRemove(item))).toList(),
        ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: colors.fg, fontWeight: FontWeight.w700)),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            InkWell(onTap: onRemove, child: Icon(Icons.close_rounded, size: 14, color: colors.fg)),
          ],
        ],
      ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBubble(icon: icon),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.35)),
            ],
          ),
        ),
      ],
    );
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
  final double value;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(trailing, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(value: value, minHeight: 8),
          ),
        ],
      ),
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
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
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

String _normalize(String value) {
  return value.toLowerCase().replaceAll('ё', 'е').trim();
}
