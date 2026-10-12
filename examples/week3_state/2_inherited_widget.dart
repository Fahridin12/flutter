// Неделя 3, шаг 2: то же самое через InheritedWidget.
// Запуск: flutter run -t examples/week3_state/2_inherited_widget.dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: FavoritesHost(child: FavoritesScreen())));

/// Хранит состояние и пересоздаёт InheritedWidget при изменении.
class FavoritesHost extends StatefulWidget {
  const FavoritesHost({super.key, required this.child});

  final Widget child;

  @override
  State<FavoritesHost> createState() => _FavoritesHostState();
}

class _FavoritesHostState extends State<FavoritesHost> {
  final Set<String> _favorites = {};

  void _toggle(String title) {
    setState(() {
      if (!_favorites.add(title)) _favorites.remove(title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FavoritesScope(
      favorites: Set.of(_favorites),
      toggle: _toggle,
      child: widget.child,
    );
  }
}

class FavoritesScope extends InheritedWidget {
  const FavoritesScope({
    super.key,
    required this.favorites,
    required this.toggle,
    required super.child,
  });

  final Set<String> favorites;
  final void Function(String title) toggle;

  static FavoritesScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope != null, 'FavoritesScope не найден выше по дереву');
    return scope!;
  }

  @override
  bool updateShouldNotify(FavoritesScope old) => favorites.length != old.favorites.length ||
      !favorites.containsAll(old.favorites);
}

const _titles = ['Dune', 'Идиот', 'Solaris', 'Мастер и Маргарита'];

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = FavoritesScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('InheritedWidget — избранное: ${scope.favorites.length}')),
      body: ListView(
        children: [
          for (final t in _titles)
            ListTile(
              title: Text(t),
              trailing: IconButton(
                icon: Icon(scope.favorites.contains(t) ? Icons.favorite : Icons.favorite_border),
                onPressed: () => scope.toggle(t),
              ),
            ),
        ],
      ),
    );
  }
}
// Плюс: состояние доступно любому потомку без прокидывания через конструкторы.
// Минус: много шаблонного кода (Host + Scope + of + updateShouldNotify).
