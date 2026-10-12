import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../domain/entities/reading_status.dart';

extension ReadingStatusUi on ReadingStatus {
  IconData get icon => switch (this) {
        ReadingStatus.wantToRead => Icons.bookmark_add_outlined,
        ReadingStatus.reading => Icons.auto_stories,
        ReadingStatus.finished => Icons.check_circle_outline,
      };

  String label(AppStrings s) => switch (this) {
        ReadingStatus.wantToRead => s.statusWant,
        ReadingStatus.reading => s.statusReading,
        ReadingStatus.finished => s.statusFinished,
      };
}
