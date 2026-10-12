import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/reading_status.dart';
import '../common/status_ui.dart';
import 'library_bloc.dart';

/// Добавление книги вручную, правка существующей или добавление найденной в поиске (initial).
class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key, this.initial});

  final Book? initial;

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _pages;
  late final TextEditingController _year;
  late final TextEditingController _isbn;
  late ReadingStatus _status;
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    final b = widget.initial;
    _title = TextEditingController(text: b?.title ?? '');
    _author = TextEditingController(text: b?.author ?? '');
    _pages = TextEditingController(text: b?.pageCount?.toString() ?? '');
    _year = TextEditingController(text: b?.year?.toString() ?? '');
    _isbn = TextEditingController(text: b?.isbn ?? '');
    _status = b?.status ?? ReadingStatus.wantToRead;
    _isEditing = b != null && context.read<LibraryBloc>().state.books.any((x) => x.id == b.id);
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    _year.dispose();
    _isbn.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final base = widget.initial;
    final isbn = _isbn.text.trim();

    var book = Book(
      id: base?.id ?? now.microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      author: _author.text.trim(),
      isbn: isbn.isEmpty ? null : isbn,
      pageCount: int.tryParse(_pages.text.trim()),
      year: int.tryParse(_year.text.trim()),
      coverUrl: base?.coverUrl,
      status: base?.status ?? ReadingStatus.wantToRead,
      currentPage: base?.currentPage ?? 0,
      rating: base?.rating,
      note: base?.note,
      addedAt: base?.addedAt ?? now,
      updatedAt: now,
      finishedAt: base?.finishedAt,
    );
    if (book.status != _status) book = book.changeStatus(_status);

    context.read<LibraryBloc>().add(LibraryBookSaved(book));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    const border = OutlineInputBorder();

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? s.editBook : s.newBook)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _title,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: '${s.titleLabel} *', border: border),
                  validator: (v) => (v == null || v.trim().isEmpty) ? s.required : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _author,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: '${s.authorLabel} *', border: border),
                  validator: (v) => (v == null || v.trim().isEmpty) ? s.required : null,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pages,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(labelText: s.pages, border: border),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return null;
                          final n = int.tryParse(t);
                          return (n == null || n <= 0 || n > 20000) ? s.invalidNumber : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _year,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(labelText: s.year, border: border),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return null;
                          final n = int.tryParse(t);
                          return (n == null || n < 1 || n > DateTime.now().year + 1)
                              ? s.invalidNumber
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _isbn,
                  decoration: const InputDecoration(labelText: 'ISBN', border: border),
                  validator: (v) {
                    final t = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
                    if (t.isEmpty) return null;
                    return RegExp(r'^(\d{9}[\dXx]|\d{13})$').hasMatch(t) ? null : s.invalidIsbn;
                  },
                ),
                const SizedBox(height: 24),
                Text(s.status, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<ReadingStatus>(
                  showSelectedIcon: false,
                  segments: [
                    for (final st in ReadingStatus.values)
                      ButtonSegment(value: st, label: Text(st.label(s))),
                  ],
                  selected: {_status},
                  onSelectionChanged: (set) => setState(() => _status = set.first),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: Text(s.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
