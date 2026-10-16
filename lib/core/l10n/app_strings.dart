import 'package:flutter/widgets.dart';

import '../../domain/entities/library_filter.dart';
import '../../domain/failure.dart';
import '../../presentation/auth/auth_bloc.dart';

/// Простая локализация RU/EN без кодогенерации.
/// Использование: `context.s.library`.
class AppStrings {
  const AppStrings(this.languageCode);

  final String languageCode;

  bool get _ru => languageCode == 'ru';

  String _t(String ru, String en) => _ru ? ru : en;

  static AppStrings of(BuildContext context) =>
      AppStrings(Localizations.localeOf(context).languageCode);

  // ---- Навигация ----
  String get library => _t('Библиотека', 'Library');
  String get search => _t('Поиск', 'Search');
  String get stats => _t('Статистика', 'Stats');
  String get settings => _t('Настройки', 'Settings');

  // ---- Общие ----
  String get retry => _t('Повторить', 'Retry');
  String get cancel => _t('Отмена', 'Cancel');
  String get save => _t('Сохранить', 'Save');
  String get delete => _t('Удалить', 'Delete');
  String get edit => _t('Изменить', 'Edit');
  String get required => _t('Обязательное поле', 'Required field');
  String get invalidNumber => _t('Некорректное число', 'Invalid number');
  String get invalidIsbn => _t('ISBN: 10 или 13 цифр', 'ISBN: 10 or 13 digits');
  String get loadError => _t('Не удалось загрузить данные', 'Failed to load data');

  // ---- Статусы ----
  String get status => _t('Статус', 'Status');
  String get statusWant => _t('Хочу прочитать', 'Want to read');
  String get statusReading => _t('Читаю', 'Reading');
  String get statusFinished => _t('Прочитано', 'Finished');

  String filterLabel(LibraryFilter f) => switch (f) {
        LibraryFilter.all => _t('Все', 'All'),
        LibraryFilter.wantToRead => statusWant,
        LibraryFilter.reading => statusReading,
        LibraryFilter.finished => statusFinished,
      };

  // ---- Библиотека ----
  String get myLibrary => _t('Моя библиотека', 'My library');
  String get addBook => _t('Добавить', 'Add');
  String get newBook => _t('Новая книга', 'New book');
  String get editBook => _t('Редактирование', 'Edit book');
  String get emptyLibraryTitle => _t('Библиотека пуста', 'Your library is empty');
  String get emptyLibrarySubtitle =>
      _t('Найдите книгу в каталоге или добавьте вручную', 'Find a book in the catalog or add one manually');
  String get emptyFilterTitle => _t('Нет книг с таким статусом', 'No books with this status');
  String get findBook => _t('Найти книгу', 'Find a book');
  String get bookNotFound => _t('Книга не найдена', 'Book not found');
  String get unknownAuthor => _t('Автор неизвестен', 'Unknown author');
  String get titleLabel => _t('Название', 'Title');
  String get authorLabel => _t('Автор', 'Author');
  String get pages => _t('Страниц', 'Pages');
  String get year => _t('Год', 'Year');
  String get rating => _t('Оценка', 'Rating');
  String get note => _t('Заметка', 'Note');
  String get saveNote => _t('Сохранить заметку', 'Save note');
  String get noteSaved => _t('Заметка сохранена', 'Note saved');
  String get addedOn => _t('Добавлена', 'Added');
  String get finishedOn => _t('Прочитана', 'Finished');
  String get deleteTitle => _t('Удалить книгу?', 'Delete book?');
  String deleteConfirm(String title) =>
      _t('«$title» будет удалена из библиотеки.', '"$title" will be removed from your library.');
  String pagesShort(int n) => _t('$n стр.', '$n pp.');
  String pageOf(int current, int total) =>
      _t('Страница $current из $total', 'Page $current of $total');
  String formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  // ---- Поиск ----
  String get searchHint => _t('Название, автор или ISBN', 'Title, author or ISBN');
  String get searchInitialTitle => _t('Каталог Open Library', 'Open Library catalog');
  String get searchInitialSubtitle =>
      _t('Введите минимум 2 символа', 'Type at least 2 characters');
  String get nothingFound => _t('Ничего не найдено', 'Nothing found');
  String get nothingFoundHint => _t('Попробуйте изменить запрос', 'Try a different query');
  String get offlineResults =>
      _t('Нет сети — показаны сохранённые результаты', 'Offline — showing saved results');
  String get addToLibrary => _t('Добавить в библиотеку', 'Add to library');
  String addedToLibrary(String title) =>
      _t('«$title» добавлена в библиотеку', '"$title" added to your library');

  String failureMessage(FailureType? type) => switch (type) {
        FailureType.network => _t('Нет подключения к интернету', 'No internet connection'),
        FailureType.timeout => _t('Сервер не отвечает. Попробуйте позже', 'Server timed out. Try again later'),
        FailureType.server => _t('Ошибка сервера', 'Server error'),
        FailureType.parse => _t('Не удалось разобрать ответ сервера', 'Could not parse the server response'),
        FailureType.unknown || null => _t('Что-то пошло не так', 'Something went wrong'),
      };

  // ---- Статистика ----
  String get totalBooks => _t('Всего книг', 'Total books');
  String get pagesRead => _t('Страниц прочитано', 'Pages read');
  String get averageRating => _t('Средняя оценка', 'Average rating');
  String get yearlyGoal => _t('Цель на год', 'Yearly goal');
  String goalProgress(int done, int goal) => _t('$done из $goal книг', '$done of $goal books');
  String finishedByMonth(int year) =>
      _t('Прочитано по месяцам, $year', 'Finished by month, $year');
  String booksCount(int n) => _t('$n книг', '$n books');

  static const _monthsRu = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
  static const _monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String monthShort(int index) => _ru ? _monthsRu[index] : _monthsEn[index];

  // ---- Настройки ----
  String get theme => _t('Тема', 'Theme');
  String get themeSystem => _t('Системная', 'System');
  String get themeLight => _t('Светлая', 'Light');
  String get themeDark => _t('Тёмная', 'Dark');
  String get language => _t('Язык', 'Language');
  String get notifications => _t('Push-уведомления', 'Push notifications');
  String get enablePush => _t('Включить уведомления', 'Enable notifications');
  String get pushEnabled => _t('Уведомления включены. FCM-токен устройства:', 'Notifications enabled. Device FCM token:');
  String get copyToken => _t('Скопировать токен', 'Copy token');
  String get tokenCopied => _t('Токен скопирован', 'Token copied');
  String get account => _t('Аккаунт', 'Account');
  String get signOut => _t('Выйти', 'Sign out');

  // ---- Авторизация ----
  String get loginTitle => _t('Вход в аккаунт', 'Sign in');
  String get registerTitle => _t('Создание аккаунта', 'Create account');
  String get loginAction => _t('Войти', 'Sign in');
  String get registerAction => _t('Зарегистрироваться', 'Sign up');
  String get continueWithGoogle => _t('Продолжить с Google', 'Continue with Google');
  String get noAccount => _t('Нет аккаунта? Зарегистрируйтесь', "Don't have an account? Sign up");
  String get haveAccount => _t('Уже есть аккаунт? Войти', 'Already have an account? Sign in');
  String get forgotPassword => _t('Забыли пароль?', 'Forgot password?');
  String get nameLabel => _t('Имя (необязательно)', 'Name (optional)');
  String get passwordLabel => _t('Пароль', 'Password');
  String get passwordTooShort => _t('Минимум 6 символов', 'At least 6 characters');
  String get invalidEmail => _t('Введите корректный email', 'Enter a valid email');
  String get enterEmailFirst => _t('Сначала введите email', 'Enter your email first');
  String get demoSignIn => _t('Быстрый демо-вход', 'Quick demo sign-in');
  String get offlineSignIn => _t('Войти в офлайн-режиме (без Firebase)', 'Continue in offline mode');

  String authNotice(AuthNotice n) => switch (n) {
        AuthNotice.invalidCredentials => _t('Неверный email или пароль', 'Wrong email or password'),
        AuthNotice.emailInUse => _t('Этот email уже зарегистрирован', 'This email is already registered'),
        AuthNotice.weakPassword => _t('Слишком простой пароль', 'Password is too weak'),
        AuthNotice.invalidEmail => invalidEmail,
        AuthNotice.network => _t('Нет подключения к интернету', 'No internet connection'),
        AuthNotice.operationNotAllowed => _t(
            'Провайдер Email/Password не включён в Firebase Console! Включите его в Authentication -> Sign-in method.',
            'Email/Password sign-in provider is not enabled in Firebase Console! Enable it in Authentication -> Sign-in method.',
          ),
        AuthNotice.unknown => _t('Не удалось выполнить вход', 'Sign-in failed'),
        AuthNotice.resetEmailSent => _t('Письмо для сброса пароля отправлено', 'Password reset email sent'),
      };
}

extension AppStringsContext on BuildContext {
  AppStrings get s => AppStrings.of(this);
}
