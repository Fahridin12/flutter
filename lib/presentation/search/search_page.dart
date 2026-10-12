import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_status.dart';
import '../common/book_tile.dart';
import '../common/state_views.dart';
import '../common/status_ui.dart';
import '../library/library_bloc.dart';
import 'search_bloc.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (_) => getIt<SearchBloc>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.search)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _controller,
              hintText: s.searchHint,
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    context.read<SearchBloc>().add(const SearchQueryChanged(''));
                  },
                ),
              ],
              onChanged: (v) => context.read<SearchBloc>().add(SearchQueryChanged(v)),
            ),
          ),
          const Expanded(child: _SearchResults()),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final libraryBooks = context.watch<LibraryBloc>().state.books;
    final inLibrary = {for (final b in libraryBooks) b.id};

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        switch (state.status) {
          case SearchStatus.initial:
            return EmptyView(
              icon: Icons.travel_explore,
              title: s.searchInitialTitle,
              subtitle: s.searchInitialSubtitle,
            );
          case SearchStatus.loading:
            return const LoadingView();
          case SearchStatus.empty:
            return EmptyView(
              icon: Icons.search_off,
              title: s.nothingFound,
              subtitle: s.nothingFoundHint,
            );
          case SearchStatus.failure:
            return ErrorView(
              message: s.failureMessage(state.failure),
              onRetry: () => context.read<SearchBloc>().add(const SearchRefreshed()),
            );
          case SearchStatus.success:
            return Column(
              children: [
                if (state.fromCache) const _OfflineBanner(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final bloc = context.read<SearchBloc>();
                      bloc.add(const SearchRefreshed());
                      await bloc.stream
                          .firstWhere((st) => st.status != SearchStatus.loading)
                          .timeout(const Duration(seconds: 20), onTimeout: () => bloc.state);
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: state.books.length,
                      separatorBuilder: (context, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final book = state.books[i];
                        return BookTile(
                          book: book,
                          onTap: () => context.pushNamed(AppRoutes.add, extra: book),
                          trailing: inLibrary.contains(book.id)
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : _AddMenu(book: book),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
        }
      },
    );
  }
}

class _AddMenu extends StatelessWidget {
  const _AddMenu({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return PopupMenuButton<ReadingStatus>(
      tooltip: s.addToLibrary,
      icon: const Icon(Icons.add_circle_outline),
      onSelected: (status) {
        context.read<LibraryBloc>().add(LibraryBookSaved(book.changeStatus(status)));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(s.addedToLibrary(book.title))));
      },
      itemBuilder: (context) => [
        for (final st in ReadingStatus.values)
          PopupMenuItem(
            value: st,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(st.icon),
              title: Text(st.label(s)),
            ),
          ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.s.offlineResults,
              style: TextStyle(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
