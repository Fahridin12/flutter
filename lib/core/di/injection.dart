import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/firestore_library_data_source.dart';
import '../../data/datasources/local_library_storage.dart';
import '../../data/datasources/open_library_api.dart';
import '../../data/datasources/search_cache_storage.dart';
import '../../data/repositories/demo_auth_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/library_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../data/services/push_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../presentation/auth/auth_bloc.dart';
import '../../presentation/library/library_bloc.dart';
import '../../presentation/search/search_bloc.dart';
import '../../presentation/settings/settings_controller.dart';
import '../network/dio_client.dart';

final GetIt getIt = GetIt.instance;

/// Dependency Injection (get_it): data -> domain -> presentation.
Future<void> configureDependencies(SharedPreferences prefs, {bool firebaseAvailable = false}) async {
  getIt
    // Внешние зависимости
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<Dio>(createDioClient)
    // Data
    ..registerLazySingleton<OpenLibraryApi>(() => OpenLibraryApi(getIt<Dio>()))
    ..registerLazySingleton<SearchCacheStorage>(SearchCacheStorage.new)
    ..registerLazySingleton<AuthRepository>(() {
      if (firebaseAvailable) {
        return FirebaseAuthRepository(
          FirebaseAuth.instance,
          kIsWeb ? null : GoogleSignIn(),
        );
      } else {
        return DemoAuthRepository();
      }
    })
    ..registerLazySingleton<LocalLibraryStorage>(
      () => LocalLibraryStorage(() => getIt<AuthRepository>().currentUser?.uid),
    )
    ..registerLazySingleton<FirestoreLibraryDataSource>(() {
      if (firebaseAvailable) {
        return FirestoreLibraryDataSource(FirebaseFirestore.instance);
      } else {
        return FirestoreLibraryDataSource();
      }
    })
    ..registerLazySingleton<PushService>(() {
      if (firebaseAvailable) {
        return PushService(
          FirebaseMessaging.instance,
          FirebaseFirestore.instance,
          getIt<AuthRepository>(),
        );
      } else {
        return PushService(null, null, getIt<AuthRepository>());
      }
    })
    // Domain (интерфейсы репозиториев -> реализации)
    ..registerLazySingleton<LibraryRepository>(
      () => LibraryRepositoryImpl(
        local: getIt<LocalLibraryStorage>(),
        remote: getIt<FirestoreLibraryDataSource>(),
        auth: getIt<AuthRepository>(),
      ),
    )
    ..registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(
        api: getIt<OpenLibraryApi>(),
        cache: getIt<SearchCacheStorage>(),
      ),
    )
    // Presentation
    ..registerLazySingleton<SettingsController>(
      () => SettingsController(getIt<SharedPreferences>()),
    )
    ..registerLazySingleton<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()))
    ..registerLazySingleton<LibraryBloc>(() => LibraryBloc(getIt<LibraryRepository>()))
    ..registerFactory<SearchBloc>(() => SearchBloc(getIt<SearchRepository>()));
}
