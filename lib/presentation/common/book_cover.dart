import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Обложка книги с кэшированием и заглушкой.
class BookCover extends StatelessWidget {
  const BookCover({super.key, this.url, this.width = 56, this.height = 80});

  final String? url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.menu_book, color: scheme.onSurfaceVariant),
    );
    final imageUrl = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl == null
            ? placeholder
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, _) => placeholder,
                errorWidget: (context, _, __) => placeholder,
              ),
      ),
    );
  }
}
