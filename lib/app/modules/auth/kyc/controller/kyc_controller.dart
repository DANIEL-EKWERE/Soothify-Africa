import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/kyc_question.dart';
import '../../../../data/repositories/kyc_repository.dart';

class KycController extends BaseController {
  KycController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final KycRepository _repository;

  /// Injectable so the birth-year wheel and the age it prints are fixed in a
  /// test rather than drifting with the calendar.
  final DateTime Function() _now;

  final RxInt step = 0.obs;

  /// Question id -> chosen option values.
  final RxMap<String, Set<String>> answers = <String, Set<String>>{}.obs;

  /// The year the birth-year wheel is measured against.
  late final int currentYear = _now().year;

  /// Held once: [KycQuestion.allFor] builds a fresh list each call, and the
  /// screen reads `question` several times per frame.
  late final List<KycQuestion> questions = KycQuestion.allFor(currentYear);

  int get totalSteps => questions.length;

  KycQuestion get question => questions[step.value];

  Set<String> get current => answers[question.id] ?? const {};

  bool isChosen(KycOption option) => current.contains(option.value);

  /// The design disables Next until the question has an answer.
  bool get canProceed => current.isNotEmpty;

  bool get isLastStep => step.value == totalSteps - 1;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  /// Restores a part-finished questionnaire and resumes at the first
  /// unanswered question, so a returning user does not redo their work.
  Future<void> _restore() async {
    final saved = await guard(
      () => _repository.savedAnswers(),
      showFeedback: false,
    );
    if (saved == null || saved.isEmpty) return;

    answers.addAll(saved);
    final next = questions.indexWhere((q) => (saved[q.id] ?? const {}).isEmpty);
    step.value = next == -1 ? totalSteps - 1 : next;
  }

  void choose(KycOption option) {
    final q = question;
    final chosen = Set<String>.from(current);

    if (q.isMulti) {
      chosen.contains(option.value)
          ? chosen.remove(option.value)
          : chosen.add(option.value);
    } else {
      // Single-choice and wheel questions hold exactly one value.
      chosen
        ..clear()
        ..add(option.value);
    }

    answers[q.id] = chosen;
    answers.refresh();
  }

  void back() {
    if (step.value > 0) step.value -= 1;
  }

  Future<void> next() async {
    if (!canProceed || isLoading.value) return;

    if (!isLastStep) {
      // Persist as we go so an interrupted questionnaire is not lost.
      await guard(() => _repository.saveAnswers(Map.of(answers)),
          showFeedback: false);
      step.value += 1;
      return;
    }

    final ok = await guard(() async {
      await _repository.saveAnswers(Map.of(answers));
      await _repository.markComplete();
      return true;
    });
    if (ok == true) Get.offAllNamed(AppRoutes.shell);
  }
}
