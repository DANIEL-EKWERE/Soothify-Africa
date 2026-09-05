import '../../../../core/app_export.dart';
import '../../../../data/models/wellness_kyc.dart';

/// Runs a section's pre-booking questionnaire — Figma "meditation"
/// (135:23481 onward) and "Scheduling Kyc" (135:23889 onward).
///
/// One intro screen, then a question per step, then the booking flow. The
/// answer to each step is kept so the backend can match a coach later; only
/// the completion flag is persisted for now, since nothing consumes the
/// answers yet and storing them would imply they are being used.
class WellnessKycController extends GetxController {
  WellnessKycController(this.track);

  final WellnessTrack track;

  /// -1 is the intro; 0..steps.length-1 are the questions. Tracks without an
  /// intro frame start on the first question.
  late final RxInt index = (track.hasIntro ? -1 : 0).obs;

  /// Step index to the options chosen for it.
  final RxMap<int, Set<String>> answers = <int, Set<String>>{}.obs;

  bool get onIntro => index.value < 0;

  WellnessKycStep get step => track.steps[index.value];

  bool get isLastStep => index.value == track.steps.length - 1;

  /// The design labels the final step's button "Continue" and the rest "Next".
  String get actionLabel => isLastStep ? 'Continue' : 'Next';

  Set<String> get selected => answers[index.value] ?? const {};

  bool isSelected(String option) => selected.contains(option);

  /// The button is drawn at 45% until something is chosen.
  bool get canAdvance => selected.isNotEmpty;

  void begin() => index.value = 0;

  void choose(String option) {
    final current = {...selected};
    if (step.multiSelect) {
      if (!current.remove(option)) current.add(option);
    } else {
      current
        ..clear()
        ..add(option);
    }
    answers[index.value] = current;
    answers.refresh();
  }

  Future<void> next() async {
    if (!canAdvance) return;
    if (!isLastStep) {
      index.value += 1;
      return;
    }
    await PrefUtils().setWellnessKycDone(track.name);
    // Straight into booking — the questionnaire exists to match a coach.
    await Get.offNamed(AppRoutes.schedule);
  }

  void back() {
    if (index.value <= 0) {
      Get.back();
    } else {
      index.value -= 1;
    }
  }
}
