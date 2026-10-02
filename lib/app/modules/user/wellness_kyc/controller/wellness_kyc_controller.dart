import 'dart:async';

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
  WellnessKycController(
    this.track, {
    Duration? introWait,
    this.skipIntro = false,
  }) : _introWait = introWait ?? const Duration(milliseconds: 2400);

  /// Opens straight on the first question, whatever the track draws.
  ///
  /// Set when the questionnaire is reached from a card on "Book a licensed
  /// expert screen": the card already named the discipline, so the
  /// interstitial that would introduce it has nothing left to say.
  final bool skipIntro;

  /// How long the intro's bar takes to fill before it advances.
  ///
  /// [Duration.zero] holds the intro open indefinitely — what a golden of
  /// that screen needs, and what stops a periodic timer outliving a test.
  final Duration _introWait;

  final WellnessTrack track;

  /// -1 is the intro; 0..steps.length-1 are the questions.
  ///
  /// Every track opens on an interstitial of its own — Pilates & Core
  /// `259:38525`, Stretch & Restore `259:38802`, therapy `259:38773` — so
  /// only [skipIntro] sends a track straight to its first question.
  late final RxInt index = (skipIntro ? 0 : -1).obs;

  /// Step index to the options chosen for it.
  final RxMap<int, Set<String>> answers = <int, Set<String>>{}.obs;

  bool get onIntro => index.value < 0;

  /// How full the intro's bar is, 0..1.
  final RxDouble introProgress = 0.0.obs;

  Timer? _intro;

  /// The intro carries a progress bar — `Pilates kyc` (259:38525) and
  /// `Scheduling Kyc/Yoga` (259:38802) both draw one 24 below the paragraph.
  /// That is why the frame gives the screen no button: it is loading, and it
  /// moves on by itself. Tapping still skips ahead, though nothing says so
  /// on screen any more.
  ///
  /// The frames park the fill at 128 of 280.7, which is a still frame drawing
  /// motion rather than a measurement — so this runs it as a real wait.
  @override
  void onInit() {
    super.onInit();
    if (!onIntro || _introWait == Duration.zero) return;
    const tick = Duration(milliseconds: 60);
    final total = _introWait;
    var elapsed = Duration.zero;
    _intro = Timer.periodic(tick, (t) {
      elapsed += tick;
      introProgress.value =
          (elapsed.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
      if (introProgress.value >= 1) {
        t.cancel();
        if (onIntro) begin();
      }
    });
  }

  @override
  void onClose() {
    _intro?.cancel();
    super.onClose();
  }

  WellnessKycStep get step => track.steps[index.value];

  bool get isLastStep => index.value == track.steps.length - 1;

  /// The design labels the final step's button "Continue" and the rest "Next".
  String get actionLabel => isLastStep ? 'Continue' : 'Next';

  Set<String> get selected => answers[index.value] ?? const {};

  bool isSelected(String option) => selected.contains(option);

  /// The button is drawn at 45% until something is chosen.
  bool get canAdvance => selected.isNotEmpty;

  void begin() {
    _intro?.cancel();
    index.value = 0;
  }

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
    // Every track goes straight to matching now. The three gradient
    // offering cards (`ScheduleScreen`) used to sit between the
    // questionnaire and the match for Pilates & Core and Stretch & Restore;
    // that card design is retired, and all three disciplines run
    // questionnaire -> matching -> matched, as the therapy row always did.
    await Get.offNamed(AppRoutes.booking, arguments: track.offering);
  }

  void back() {
    if (index.value <= 0) {
      Get.back();
    } else {
      index.value -= 1;
    }
  }
}
