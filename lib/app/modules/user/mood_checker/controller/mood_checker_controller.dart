
import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/mood.dart';
import '../../../../data/repositories/mood_repository.dart';

class MoodCheckerController extends BaseController {
  MoodCheckerController(this._repository);

  final MoodRepository _repository;

  final Rxn<Mood> selected = Rxn<Mood>();
  final RxBool isSaving = false.obs;

  /// The nine moods in design order.
  List<Mood> get moods => Mood.values;

  @override
  void onInit() {
    super.onInit();
    _loadTodays();
  }

  /// Preselects today's mood if one was already recorded, so reopening the
  /// screen reflects what the user last said rather than looking untouched.
  Future<void> _loadTodays() async {
    final entry = await guard(
      () => _repository.todaysEntry(),
      showFeedback: false,
    );
    selected.value = entry?.mood;
  }

  Future<void> select(Mood mood) async {
    if (isSaving.value) return;
    selected.value = mood;

    isSaving.value = true;
    final entry = await guard(() => _repository.record(mood));
    isSaving.value = false;

    // Roll the selection back if the write failed, so the UI never shows a
    // choice that was not actually saved.
    if (entry == null) {
      selected.value = null;
      return;
    }

    // The records screen's copy ("You have completed today's check-in")
    // places it directly after this step.
    await Get.toNamed(AppRoutes.moodRecord);
  }
}
