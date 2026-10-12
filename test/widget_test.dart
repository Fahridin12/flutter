import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reading_tracker/domain/entities/book.dart';
import 'package:reading_tracker/domain/entities/reading_status.dart';
import 'package:reading_tracker/presentation/common/book_tile.dart';
import 'package:reading_tracker/presentation/common/state_views.dart';

Widget _wrap(Widget child, [Locale locale = const Locale('ru')]) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('ru'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: Scaffold(body: child),
  );
}

void main() {
  group('Common Widgets', () {
    testWidgets('LoadingView displays CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(_wrap(const LoadingView()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('EmptyView displays title, subtitle and action', (tester) async {
      var actionTapped = false;
      await tester.pumpWidget(
        _wrap(
          EmptyView(
            icon: Icons.menu_book,
            title: 'Empty Library',
            subtitle: 'No books yet',
            action: ElevatedButton(
              onPressed: () => actionTapped = true,
              child: const Text('Add Book'),
            ),
          ),
        ),
      );

      expect(find.text('Empty Library'), findsOneWidget);
      expect(find.text('No books yet'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);

      await tester.tap(find.text('Add Book'));
      expect(actionTapped, isTrue);
    });

    testWidgets('ErrorView displays error message and triggers retry', (tester) async {
      var retryTapped = false;
      await tester.pumpWidget(
        _wrap(
          ErrorView(
            message: 'Network connection failed',
            onRetry: () => retryTapped = true,
          ),
        ),
      );

      expect(find.text('Network connection failed'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      expect(retryTapped, isTrue);
    });

    testWidgets('BookTile renders book title and author correctly', (tester) async {
      final now = DateTime(2026, 1, 1);
      final book = Book(
        id: '123',
        title: 'Master and Margarita',
        author: 'Mikhail Bulgakov',
        year: 1967,
        pageCount: 480,
        status: ReadingStatus.reading,
        currentPage: 240,
        addedAt: now,
        updatedAt: now,
      );

      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          BookTile(
            book: book,
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Master and Margarita'), findsOneWidget);
      expect(find.text('Mikhail Bulgakov'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(BookTile));
      expect(tapped, isTrue);
    });
  });
}
