import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';

/// Каркас с нижней навигацией (телефон) или боковой NavigationRail (планшет / альбомная ориентация).
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    // Повторное нажатие на активную вкладку возвращает её к корню.
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final items = <(IconData, IconData, String)>[
      (Icons.local_library_outlined, Icons.local_library, s.library),
      (Icons.search, Icons.search, s.search),
      (Icons.bar_chart_outlined, Icons.bar_chart, s.stats),
      (Icons.settings_outlined, Icons.settings, s.settings),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 600) {
          final extended = width >= 1000;
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onSelect,
                  extended: extended,
                  labelType:
                      extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
                  destinations: [
                    for (final item in items)
                      NavigationRailDestination(
                        icon: Icon(item.$1),
                        selectedIcon: Icon(item.$2),
                        label: Text(item.$3),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onSelect,
            destinations: [
              for (final item in items)
                NavigationDestination(
                  icon: Icon(item.$1),
                  selectedIcon: Icon(item.$2),
                  label: item.$3,
                ),
            ],
          ),
        );
      },
    );
  }
}
