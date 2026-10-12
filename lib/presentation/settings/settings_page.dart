import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection.dart';
import '../../core/l10n/app_strings.dart';
import '../../data/services/push_service.dart';
import '../auth/auth_bloc.dart';
import 'settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final settings = context.watch<SettingsController>();
    final theme = Theme.of(context);
    final push = getIt<PushService>();

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(s.theme, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto),
                    label: Text(s.themeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode),
                    label: Text(s.themeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode),
                    label: Text(s.themeDark),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (set) => settings.setThemeMode(set.first),
              ),
              const SizedBox(height: 24),
              Text(s.language, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'ru', label: Text('Русский')),
                  ButtonSegment(value: 'en', label: Text('English')),
                ],
                selected: {settings.locale.languageCode},
                onSelectionChanged: (set) => settings.setLanguage(set.first),
              ),
              const SizedBox(height: 24),
              Text(s.yearlyGoal, style: theme.textTheme.titleSmall),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => settings.setYearlyGoal(settings.yearlyGoal - 1),
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      s.booksCount(settings.yearlyGoal),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => settings.setYearlyGoal(settings.yearlyGoal + 1),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const Divider(height: 40),
              Text(s.notifications, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ValueListenableBuilder<String?>(
                valueListenable: push.token,
                builder: (context, token, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (token == null)
                      FilledButton.tonalIcon(
                        onPressed: push.init,
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: Text(s.enablePush),
                      )
                    else ...[
                      Text(s.pushEnabled),
                      const SizedBox(height: 4),
                      Text(
                        token,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: token));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(s.tokenCopied)));
                        },
                        icon: const Icon(Icons.copy),
                        label: Text(s.copyToken),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 40),
              Text(s.account, style: theme.textTheme.titleSmall),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(state.user?.displayName ?? state.user?.email ?? '—'),
                  subtitle: state.user?.displayName != null ? Text(state.user?.email ?? '') : null,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
                icon: const Icon(Icons.logout),
                label: Text(s.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
