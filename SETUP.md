# Запуск проекта: Library & Reading Tracker (Недели 1–8)

Проект подготовлен в соответствии со всеми требованиями тематического плана курса по 8 неделю включительно (РК1).

## 1. Подготовка окружения
Убедитесь, что установлены Flutter SDK и среда разработки:
```bash
flutter doctor            # должно быть без ошибок (требование недели 1)
```

## 2. Платформенные папки (Android / iOS)
Файлы платформы Android уже сконфигурированы в папке `android/`:
- `minSdk` = **23** (требование Firebase);
- `compileSdk` = **34**, `targetSdk` = **34**;
- Пакет приложения: `kz.almau.reading_tracker`;
- Разрешения `INTERNET` и `POST_NOTIFICATIONS` добавлены в `AndroidManifest.xml`.

Если вам понадобятся дополнительные платформы (iOS, Web, Windows), выполните:
```bash
flutter create . --org kz.almau --project-name reading_tracker --platforms=ios,web,windows
```

## 3. Зависимости и кодогенерация
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # файл search_dto.g.dart уже включен в проект
```

## 4. Быстрый запуск в демо/офлайн-режиме (без ожидания Firebase)
В проект встроен **автоматический fallback**: если ключи Firebase ещё не настроены, приложение **не падает**, а запускается в автономном режиме:
1. Запустите:
   ```bash
   flutter run
   ```
2. На экране входа нажмите кнопку **«Быстрый демо-вход»** (или войдите под любым email).
3. Все экраны работают: личная библиотека (Hive), карточки книг, редактирование и заметки, поиск в реальном Open Library API, расчёт статистики и диаграммы, светлая/тёмная тема, переключение языка.

## 5. Подключение реального Firebase (требование недели 8)
1. Создайте проект в [Firebase Console](https://console.firebase.google.com/).
2. В разделе **Authentication → Sign-in method**: включите *Email/Password* и *Google*.
3. Для Google-входа добавьте SHA-1 отпечаток отладочного ключа:
   ```bash
   cd android && ./gradlew signingReport
   ```
   Скопируйте `SHA-1` в *Project settings → Your apps → Android → Add fingerprint*.
4. В разделе **Firestore Database**: создайте базу данных (production mode), затем скопируйте содержимое файла `firestore.rules` на вкладку *Rules* и нажмите *Publish*.
5. Сконфигурируйте FlutterFire:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure     # автоматически обновит lib/firebase_options.dart и добавит google-services.json
   ```

## 6. Запуск и тестирование
```bash
flutter run                 # запуск на эмуляторе или физическом устройстве
flutter analyze             # проверка статическим анализатором
flutter test                # запуск полного набора unit-, bloc- и widget-тестов
```

### Запуск заданий отдельных недель:
- **Неделя 1 (Dart-задачи):**
  ```bash
  dart run dart_tasks/task1_null_safety.dart
  dart run dart_tasks/task2_classes.dart
  dart run dart_tasks/task3_collections.dart
  dart run dart_tasks/task4_async.dart
  ```
- **Неделя 3 (Сравнение управления состоянием):**
  ```bash
  flutter run -t examples/week3_state/1_setstate.dart
  flutter run -t examples/week3_state/2_inherited_widget.dart
  flutter run -t examples/week3_state/3_provider.dart
  ```

## 7. Проверка Push-уведомлений (FCM)
1. Запустите приложение на Android-устройстве и разрешите уведомления.
2. Перейдите во вкладку *Настройки → Скопировать токен*.
3. В Firebase Console откройте *Messaging → Create your first campaign → Firebase Notification messages → Send test message* и вставьте скопированный токен.
4. При открытом приложении появится `SnackBar` с текстом уведомления; при свёрнутом — системное push-уведомление Android.

## Возможные вопросы и решения
| Вопрос | Решение |
| --- | --- |
| Ошибка Google-входа: `ApiException: 10` | Не добавлен SHA-1 отпечаток ключа в Firebase Console |
| Ошибка `PERMISSION_DENIED` в Firestore | Проверьте, опубликованы ли правила из `firestore.rules` |
| Конфликт версий при `pub get` | Запустите `flutter pub upgrade --major-versions` |
| Нет системных уведомлений на Android 13+ | Убедитесь, что разрешение на показ уведомлений выдано в настройках системы |
