import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/mood.dart';
import '../../../../data/repositories/kyc_repository.dart';
import '../../../../data/repositories/mood_repository.dart';

/// Backs the Mood Checker slider.
///
/// The screen was a grid of nine emoji; the design replaced it with one
/// character illustration and a slider from "Awful" to "Awesome". Nothing is
/// written until the user commits with the button, so dragging around to look
/// at the faces does not keep rewriting today's entry.
class MoodCheckerController extends BaseController {
  MoodCheckerController(this._repository, this._kyc);

  final MoodRepository _repository;
  final KycRepository _kyc;

  /// The handle's position, 0..1. Starts mid-track so the slider reads as
  /// untouched rather than as an "Awful" the user never chose.
  final RxDouble score = 0.5.obs;

  /// Which character is drawn — the user's own, from their KYC answer.
  final Rx<MoodFigure> figure = MoodFigure.female.obs;

  final RxBool isSaving = false.obs;

  MoodLevel get level => MoodLevel.forScore(score.value);

  String get artPath => figure.value.artFor(level);

  @override
  void onInit() {
    super.onInit();
    _loadFigure();
    _loadTodays();
  }

  Future<void> _loadFigure() async {
    final answers = await guard(
      () => _kyc.savedAnswers(),
      showFeedback: false,
    );
    figure.value = MoodFigure.fromKycAnswer(answers?['gender']?.firstOrNull);
  }

  /// Puts the handle back where the user left it if they already checked in
  /// today, so reopening reflects what they said rather than looking untouched.
  Future<void> _loadTodays() async {
    final entry = await guard(
      () => _repository.todaysEntry(),
      showFeedback: false,
    );
    if (entry != null) score.value = entry.score;
  }

  void setScore(double value) => score.value = value.clamp(0.0, 1.0);

  /// The design's only action is "Add Detail". There is no frame behind it —
  /// no note composer is drawn anywhere for this flow — so it commits the
  /// score and moves on to the records screen, which is where the old flow
  /// ended and whose copy ("Nice job today") follows from it.
  Future<void> submit() async {
    if (isSaving.value) return;
    isSaving.value = true;
    final entry = await guard(() => _repository.record(score.value));
    isSaving.value = false;
    if (entry == null) return;
    await Get.toNamed(AppRoutes.moodRecord);
  }
}
