
import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/checkin_kind.dart';
import '../../../../data/models/profile_stats.dart';
import '../../../../data/repositories/profile_repository.dart';

/// Backs the Profile tab — Figma "Profile/dashboard" (135:8098).
class ProfileTabController extends BaseController {
  ProfileTabController(this._repository);

  final ProfileRepository _repository;

  final Rx<ProfileSection> section = ProfileSection.dashboard.obs;
  final Rx<ProfileStats> stats = ProfileStats.empty.obs;

  List<ProfileSection> get sections => ProfileSection.values;

  /// The month the History calendar is showing. The design prints August 2024.
  final Rx<DateTime> month = DateTime(2024, 8).obs;

  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  void selectDate(DateTime date) => selectedDate.value = date;

  void confirmDate() {
    final date = selectedDate.value;
    if (date == null) return;
    // Nothing records sessions yet, so there is no history to open — the
    // frame's own empty state says as much.
    AppFeedback.info('No sessions on ${date.day}/${date.month} yet.');
  }

  /// Each check-in kind opens its own calendar of entries.
  void openCheckin(CheckinKind kind) =>
      Get.toNamed(AppRoutes.checkin, arguments: kind);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        stats.value = await _repository.getStats();
      });

  void select(ProfileSection value) => section.value = value;

  void openSessionNote() =>
      AppFeedback.info('Session notes are not built yet.');
}
