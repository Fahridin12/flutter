import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../common/book_tile.dart';
import '../common/state_views.dart';
import 'library_bloc.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.myLibrary),
        actions: [
          BlocBuilder<LibraryBloc, LibraryState>(
            buildWhen: (p, c) => p.isSyncing != c.isSyncing,
            builder: (context, state) => state.isSyncing
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoutes.add),
        icon: const Icon(Icons.add),
        label: Text(s.addBook),
      ),
      body: const Column(
        children: [
          _FilterBar(),
          Expanded(child: _LibraryBody()),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (p, c) => p.filter != c.filter,
      builder: (context, state) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            for (final f in LibraryFilter.values) ...[
              ChoiceChip(
                label: Text(s.filterLabel(f)),
                selected: state.filter == f,
                onSelected: (_) => context.read<LibraryBloc>().add(LibraryFilterChanged(f)),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _LibraryBody extends StatelessWidget {
  const _LibraryBody();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final bloc = context.read<LibraryBloc>();

    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        if (state.status == LibraryLoadStatus.initial ||
            state.status == LibraryLoadStatus.loading) {
          return const LoadingView();
        }
        if (state.status == LibraryLoadStatus.failure) {
          return ErrorView(
            message: s.loadError,
            onRetry: () => bloc.add(const LibraryStarted()),
          );
        }

        final books = state.visibleBooks;
        if (books.isEmpty) {
          final noBooksAtAll = state.books.isEmpty;
          return EmptyView(
            icon: Icons.menu_book_outlined,
            title: noBooksAtAll ? s.emptyLibraryTitle : s.emptyFilterTitle,
            subtitle: noBooksAtAll ? s.emptyLibrarySubtitle : null,
            action: noBooksAtAll
                ? FilledButton.icon(
                    onPressed: () => context.go('/search'),
                    icon: const Icon(Icons.search),
                    label: Text(s.findBook),
                  )
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            bloc.add(const LibrarySyncRequested());
            await bloc.stream
                .firstWhere((st) => !st.isSyncing)
                .timeout(const Duration(seconds: 20), onTimeout: () => bloc.state);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              void open(String id) =>
                  context.goNamed(AppRoutes.bookDetails, pathParameters: {'id': id});

              // Планшет / альбомная ориентация — сетка, телефон — список.
              if (constraints.maxWidth >= 700) {
                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    mainAxisExtent: 136,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, i) =>
                      BookTile(book: books[i], onTap: () => open(books[i].id)),
                );
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: books.length,
                separatorBuilder: (context, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) =>
                    BookTile(book: books[i], onTap: () => open(books[i].id)),
              );
            },
          ),
        );
      },
    );
  }
}
