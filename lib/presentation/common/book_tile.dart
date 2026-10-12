import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_status.dart';
import 'book_cover.dart';
import 'status_ui.dart';

class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book, this.onTap, this.trailing});

  final Book book;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final meta = [
      if (book.year != null) '${book.year}',
      if (book.pageCount != null) s.pagesShort(book.pageCount!),
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(url: book.coverUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      book.author.isEmpty ? s.unknownAuthor : book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    if (meta.isNotEmpty)
                      Text(
                        meta,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    const SizedBox(height: 6),
                    if (book.status == ReadingStatus.reading && book.pageCount != null)
                      LinearProgressIndicator(value: book.progress)
                    else
                      _StatusBadge(status: book.status),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ReadingStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, size: 14, color: scheme.onSecondaryContainer),
            const SizedBox(width: 4),
            Text(
              status.label(context.s),
              style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSecondaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}
