import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/app_language.dart';
import '../../../../data/services/language_service.dart';

class LanguageController extends BaseController {
  LanguageController(this._service);

  final LanguageService _service;

  final Rxn<AppLanguage> selected = Rxn<AppLanguage>();

  List<AppLanguage> get languages => AppLanguage.values;

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
    if (ok == true) Get.offAllNamed(AppRoutes.kyc);
  }
}
