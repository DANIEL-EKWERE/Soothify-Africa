import '../../../../core/app_export.dart';

/// "Welcome! Let's Personalize Soothify for You!" — the gate into language
/// selection (Figma 655:5377).
class PersonalizeController extends GetxController {
  /// Takes the user into the language picker.
  void onContinue() => Get.toNamed(AppRoutes.language);

  /// Skips personalisation entirely — straight into the app.
  ///
  /// It used to land on the KYC questionnaire, which is not a skip: it swapped
  /// one set of questions for another. Skip here means the same as Skip on the
  /// carousel, so it goes where that goes, and records the decision so the
  /// next launch does not send the user back to the questions they declined.
  ///
  /// The language choice is simply left unset, so [LanguageService] falls back
  /// to English.
  Future<void> onSkip() async {
    await PrefUtils().setIntroSeen(true);
    await PrefUtils().setOnboardingSkipped(true);
    Get.offAllNamed(AppRoutes.shell);
  }
}
