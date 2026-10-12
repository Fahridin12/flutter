import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_strings.dart';
import '../../domain/entities/reading_stats.dart';
import '../library/library_bloc.dart';
import '../settings/settings_controller.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final goal = context.watch<SettingsController>().yearlyGoal;

    return Scaffold(
      appBar: AppBar(title: Text(s.stats)),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          final stats = ReadingStats.fromBooks(state.books);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _GoalCard(done: stats.finishedThisYear, goal: goal),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _NumberCard(label: s.totalBooks, value: '${stats.total}'),
                      _NumberCard(label: s.statusWant, value: '${stats.wantToRead}'),
                      _NumberCard(label: s.statusReading, value: '${stats.reading}'),
                      _NumberCard(label: s.statusFinished, value: '${stats.finished}'),
                      _NumberCard(label: s.pagesRead, value: '${stats.pagesRead}'),
                      _NumberCard(
                        label: s.averageRating,
                        value: stats.averageRating?.toStringAsFixed(1) ?? '—',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    s.finishedByMonth(DateTime.now().year),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _MonthlyChart(
                    values: stats.finishedByMonth,
                    labels: [for (var m = 0; m < 12; m++) s.monthShort(m)],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.done, required this.goal});

  final int done;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final value = (done / goal).clamp(0.0, 1.0).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.yearlyGoal, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              s.goalProgress(done, goal),
              style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: value, minHeight: 8),
          ],
        ),
      ),
    );
  }
}

class _NumberCard extends StatelessWidget {
  const _NumberCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 150,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: theme.textTheme.headlineMedium),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Простая столбчатая диаграмма без сторонних библиотек.
class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart({required this.values, required this.labels});

  final List<int> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = math.max(1, values.reduce(math.max));
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (values[i] > 0) Text('${values[i]}', style: theme.textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Container(
                    height: values[i] == 0 ? 2 : 100 * values[i] / maxValue,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: values[i] == 0
                          ? theme.colorScheme.outlineVariant
                          : theme.colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i], style: theme.textTheme.labelSmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
