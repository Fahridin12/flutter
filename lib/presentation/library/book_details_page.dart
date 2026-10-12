import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_status.dart';
import '../common/book_cover.dart';
import '../common/state_views.dart';
import '../common/status_ui.dart';
import 'library_bloc.dart';

class BookDetailsPage extends StatelessWidget {
  const BookDetailsPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        final matches = state.books.where((b) => b.id == bookId);
        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyView(icon: Icons.search_off, title: context.s.bookNotFound),
          );
        }
        return _Details(book: matches.first);
      },
    );
  }
}

class _Details extends StatefulWidget {
  const _Details({required this.book});

  final Book book;

  @override
  State<_Details> createState() => _DetailsState();
}

class _DetailsState extends State<_Details> {
  late final TextEditingController _note;
  double? _dragPage;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController(text: widget.book.note ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _save(Book book) => context.read<LibraryBloc>().add(LibraryBookSaved(book));

  Future<void> _confirmDelete() async {
    final s = context.s;
    final bloc = context.read<LibraryBloc>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteTitle),
        content: Text(s.deleteConfirm(widget.book.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    bloc.add(LibraryBookDeleted(widget.book.id));
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.library);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final book = widget.book;
    final total = book.pageCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: s.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.pushNamed(AppRoutes.add, extra: book),
          ),
          IconButton(
            tooltip: s.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCover(url: book.coverUrl, width: 110, height: 160),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title, style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(
                          book.author.isEmpty ? s.unknownAuthor : book.author,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (book.year != null) Text('${s.year}: ${book.year}'),
                        if (total != null) Text('${s.pages}: $total'),
                        if (book.isbn != null) Text('ISBN: ${book.isbn}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(s.status, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<ReadingStatus>(
                showSelectedIcon: false,
                segments: [
                  for (final st in ReadingStatus.values)
                    ButtonSegment(value: st, icon: Icon(st.icon), label: Text(st.label(s))),
                ],
                selected: {book.status},
                onSelectionChanged: (set) => _save(book.changeStatus(set.first)),
              ),
              if (book.status == ReadingStatus.reading && total != null && total > 0) ...[
                const SizedBox(height: 24),
                Text(
                  s.pageOf((_dragPage ?? book.currentPage.toDouble()).round(), total),
                  style: theme.textTheme.titleSmall,
                ),
                Slider(
                  value: (_dragPage ?? book.currentPage.toDouble()).clamp(0.0, total.toDouble()).toDouble(),
                  max: total.toDouble(),
                  divisions: total > 1 ? total : null,
                  onChanged: (v) => setState(() => _dragPage = v),
                  onChangeEnd: (v) {
                    final page = v.round();
                    setState(() => _dragPage = null);
                    _save(
                      page >= total
                          ? book.changeStatus(ReadingStatus.finished)
                          : book.copyWith(currentPage: page),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              Text(s.rating, style: theme.textTheme.titleSmall),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () => _save(
                        book.rating == i
                            ? book.copyWith(clearRating: true)
                            : book.copyWith(rating: i),
                      ),
                      icon: Icon(
                        (book.rating ?? 0) >= i ? Icons.star : Icons.star_border,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _note,
                minLines: 3,
                maxLines: 8,
                maxLength: 5000,
                decoration: InputDecoration(
                  labelText: s.note,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: () {
                    _save(book.copyWith(note: _note.text.trim()));
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(s.noteSaved)));
                  },
                  child: Text(s.saveNote),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${s.addedOn}: ${s.formatDate(book.addedAt)}'
                '${book.finishedAt != null ? '\n${s.finishedOn}: ${s.formatDate(book.finishedAt!)}' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
