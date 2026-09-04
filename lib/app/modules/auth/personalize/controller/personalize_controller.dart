import '../../../../core/app_export.dart';

/// "Welcome! Let's Personalize Soothify for You!" — the gate into language
/// selection (Figma 655:5377).
class PersonalizeController extends GetxController {
  /// Takes the user into the language picker.
  void onContinue() => Get.toNamed(AppRoutes.language);

  /// Skips personalisation entirely. The language choice is simply left
  /// unset, so [LanguageService] falls back to English.
  void onSkip() => Get.offAllNamed(AppRoutes.kyc);
}
