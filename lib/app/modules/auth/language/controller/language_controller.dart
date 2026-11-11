import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/app_language.dart';
import '../../../../data/services/language_service.dart';
import '../../../user/discovery/controller/discovery_tab_controller.dart';
import '../../../user/library/controller/library_controller.dart';
import '../../../user/shell/tabs/home_tab_controller.dart';

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
      // Started, not awaited: leaving the screen should not wait on the
      // network, and `updateLocale` has just rebuilt the app -- holding the
      // frame open across a fetch is what made the pop land mid-frame.
      _refetchContent();
    } else {
      Get.offAllNamed(AppRoutes.kyc);
    }
  }

  /// Re-asks the server for the library in the language just chosen.
  ///
  /// Words on screen retranslate themselves — `updateLocale` rebuilds the
  /// app — but the media behind them was fetched with the old `?language=`
  /// and would keep showing until something else happened to reload it.
  /// Only the tabs that are actually alive are asked; one that has not been
  /// opened yet will fetch in the new language when it is.
  Future<void> _refetchContent() async {
    try {
      await Future.wait([
        if (Get.isRegistered<HomeTabController>())
          Get.find<HomeTabController>().load(),
        if (Get.isRegistered<DiscoveryTabController>())
          Get.find<DiscoveryTabController>().load(),
        if (Get.isRegistered<LibraryController>())
          Get.find<LibraryController>().load(),
      ]);
    } catch (_) {
      // Each tab already shows its own failure. Nothing here can report one
      // usefully -- the screen that asked has been popped.
    }
  }
}
