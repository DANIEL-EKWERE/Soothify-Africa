import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/app_language.dart';
import '../../../../data/services/language_service.dart';

/// Why the language screen is open.
///
/// The file draws it twice: once in the onboarding run (`259:25752`) and once
/// among the Settings frames (`259:37703`). Same screen, different exits —
/// which is what went wrong: opened from Settings it still finished with
/// `Get.offAllNamed(kyc)`, so changing your language dropped you into the
/// onboarding age question with the whole stack gone.
enum LanguageEntry {
  /// Onboarding. No way back, and the choice leads on to the KYC.
  onboarding('Next'),

  /// Settings. A back arrow, and saving returns to where it came from.
  settings('Save Language');

  const LanguageEntry(this.action);

  /// The button's label.
  final String action;
}

class LanguageController extends BaseController {
  LanguageController(this._service);

  final LanguageService _service;

  final Rxn<AppLanguage> selected = Rxn<AppLanguage>();

  List<AppLanguage> get languages => AppLanguage.values;

  /// Defaults to onboarding: that is the run that cannot pass an argument,
  /// because it is reached by `offAllNamed` from the splash.
  LanguageEntry get entry => Get.arguments is LanguageEntry
      ? Get.arguments as LanguageEntry
      : LanguageEntry.onboarding;

  bool get fromSettings => entry == LanguageEntry.settings;

  /// The design shows Next at half opacity until a language is picked.
  bool get canProceed => selected.value != null;

  @override
  void onInit() {
    super.onInit();
    // Pre-select a previous choice so returning here is not a blank slate.
    selected.value = _service.selected.value;
  }

  void select(AppLanguage language) => selected.value = language;

  Future<void> next() async {
    final choice = selected.value;
    if (choice == null || isLoading.value) return;

    final ok = await guard(() async {
      await _service.choose(choice);
      return true;
    });
    if (ok != true) return;
    if (fromSettings) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.kyc);
    }
  }
}
