// Неделя 3, шаг 1: избранные книги через setState.
// Запуск: flutter run -t examples/week3_state/1_setstate.dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: FavoritesSetState()));

const _titles = ['Dune', 'Идиот', 'Solaris', 'Мастер и Маргарита'];

class FavoritesSetState extends StatefulWidget {
  const FavoritesSetState({super.key});

  @override
  State<FavoritesSetState> createState() => _FavoritesSetStateState();
}

class _FavoritesSetStateState extends State<FavoritesSetState> {
  final Set<String> _favorites = {};

  void _toggle(String title) {
    setState(() {
      if (!_favorites.add(title)) _favorites.remove(title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('setState — избранное: ${_favorites.length}')),
      body: ListView(
        children: [
          for (final t in _titles)
            ListTile(
              title: Text(t),
              trailing: IconButton(
                icon: Icon(_favorites.contains(t) ? Icons.favorite : Icons.favorite_border),
                onPressed: () => _toggle(t),
              ),
            ),
        ],
      ),
    );
  }
}
// Минус: состояние живёт в одном виджете. Чтобы показать счётчик в другом экране,
// пришлось бы «поднимать» состояние вверх и прокидывать его через конструкторы.
