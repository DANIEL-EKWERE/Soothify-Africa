import 'package:get/get.dart';

import 'en.dart';
import 'pcm.dart';

/// What `.tr` reads.
///
/// Two catalogues, keyed by the locales [AppLanguage] carries. English is
/// the fallback, so a key that Pidgin has not been given yet still renders
/// in English rather than printing itself — which is what makes it safe to
/// translate the app a screen at a time.
///
/// Every key used anywhere must exist in [en]. A missing English key is the
/// one failure mode that reaches a user as raw text, so `test/l10n_test`
/// checks the two catalogues against each other.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'en_NG': en, 'pcm_NG': pcm};
}
