import 'dart:ui';

/// Languages offered on the "Choose Your Preferred Language" screen
/// (Figma 655:5390 / 655:5402).
///
/// Only these two are designed. Adding one is a matter of adding a value here
/// and a matching entry in the translation catalogue.
enum AppLanguage {
  english('en', 'English', Locale('en', 'NG')),
  pidgin('pcm', 'Pidgin', Locale('pcm', 'NG'));

  const AppLanguage(this.code, this.label, this.locale);

  /// Persisted and sent to the API; never displayed.
  final String code;

  /// Shown in the option row. Deliberately not translated — a language picker
  /// should name each language in a form its speakers recognise.
  final String label;

  final Locale locale;

  static AppLanguage? fromCode(String? code) {
    if (code == null) return null;
    for (final l in AppLanguage.values) {
      if (l.code == code) return l;
    }
    return null;
  }
}
