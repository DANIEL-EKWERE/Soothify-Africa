import 'package:get/get.dart';

import '../../core/utils/pref_utils.dart';
import '../models/app_language.dart';

/// Holds the chosen language and applies it to the app.
///
/// A [GetxService] because the choice outlives every route and is read during
/// startup routing. Persisting it is the whole point of the language screen —
/// a returning user must not be asked again.
class LanguageService extends GetxService {
  final Rxn<AppLanguage> selected = Rxn<AppLanguage>();

  bool get hasChosen => selected.value != null;

  /// Falls back to English so strings always resolve, even before a choice.
  AppLanguage get effective => selected.value ?? AppLanguage.english;

  Future<LanguageService> init() async {
    await PrefUtils().init();
    selected.value = AppLanguage.fromCode(PrefUtils().getLanguage());
    return this;
  }

  Future<void> choose(AppLanguage language) async {
    selected.value = language;
    await PrefUtils().setLanguage(language.code);
    Get.updateLocale(language.locale);
  }
}
