import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/push_service.dart';
import 'presentation/auth/auth_bloc.dart';
import 'presentation/library/library_bloc.dart';
import 'presentation/settings/settings_controller.dart';

class ReadingTrackerApp extends StatefulWidget {
  const ReadingTrackerApp({super.key});

  @override
  State<ReadingTrackerApp> createState() => _ReadingTrackerAppState();
}

class _ReadingTrackerAppState extends State<ReadingTrackerApp> {
  final _authBloc = getIt<AuthBloc>();
  final _libraryBloc = getIt<LibraryBloc>();
  final _settings = getIt<SettingsController>();
  final _push = getIt<PushService>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  late final GoRouter _router = createRouter(_authBloc);
  StreamSubscription<RemoteMessage>? _pushSubscription;

  @override
  void initState() {
    super.initState();
    _pushSubscription = _push.foregroundMessages.listen(_showForegroundPush);
    // Если Firebase уже восстановил сессию до подписки BlocListener.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authBloc.state.status == AuthStatus.authenticated) _onSignedIn();
    });
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    super.dispose();
  }

  void _onSignedIn() {
    _libraryBloc.add(const LibraryStarted());
    _push.init();
  }

  void _showForegroundPush(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    final text = [n.title, n.body].whereType<String>().join(': ');
    _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider — для простого глобального состояния (настройки).
        ChangeNotifierProvider<SettingsController>.value(value: _settings),
      ],
      child: MultiBlocProvider(
        // BLoC — для основной логики (аутентификация, библиотека).
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<LibraryBloc>.value(value: _libraryBloc),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              _onSignedIn();
            } else if (state.status == AuthStatus.unauthenticated) {
              _libraryBloc.add(const LibraryCleared());
            }
          },
          child: Consumer<SettingsController>(
            builder: (context, settings, _) => MaterialApp.router(
              title: 'Reading Tracker',
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: _messengerKey,
              routerConfig: _router,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: settings.themeMode,
              locale: settings.locale,
              supportedLocales: const [Locale('ru'), Locale('en')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
            ),
          ),
        ),
      ),
    );
  }
}
