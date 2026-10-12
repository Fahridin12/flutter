// Неделя 3, шаг 3: то же самое через Provider (ChangeNotifier).
// Запуск: flutter run -t examples/week3_state/3_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoritesModel(),
      child: const MaterialApp(home: FavoritesScreen()),
    ),
  );
}

class FavoritesModel extends ChangeNotifier {
  final Set<String> _favorites = {};

  Set<String> get favorites => Set.unmodifiable(_favorites);

  bool isFavorite(String title) => _favorites.contains(title);

  void toggle(String title) {
    if (!_favorites.add(title)) _favorites.remove(title);
    notifyListeners();
  }
}

const _titles = ['Dune', 'Идиот', 'Solaris', 'Мастер и Маргарита'];

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch — перестраивать при изменении; select — только при изменении нужного поля.
    final count = context.select((FavoritesModel m) => m.favorites.length);
    return Scaffold(
      appBar: AppBar(title: Text('Provider — избранное: $count')),
      body: ListView(
        children: [
          for (final t in _titles) _BookRow(title: t),
        ],
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isFav = context.select((FavoritesModel m) => m.isFavorite(title));
    return ListTile(
      title: Text(title),
      trailing: IconButton(
        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
        // read — разовый вызов метода без подписки на изменения.
        onPressed: () => context.read<FavoritesModel>().toggle(title),
      ),
    );
  }
}
// Итог: минимум кода, перерисовываются только нужные виджеты. Логика отделена от UI.
