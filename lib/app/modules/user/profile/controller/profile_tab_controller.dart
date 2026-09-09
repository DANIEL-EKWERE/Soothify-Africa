
import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/checkin_kind.dart';
import '../../../../data/models/profile_stats.dart';
import '../../../../data/services/session_service.dart';
import '../../../../data/repositories/profile_repository.dart';

/// Backs the Profile tab — Figma "Profile/dashboard" (135:8098).
class ProfileTabController extends BaseController {
  ProfileTabController(this._repository, this._session);

  final SessionService _session;

  /// Browsing without an account — Profile offers sign-up instead of stats.
  bool get isGuest => _session.isGuest;

  final ProfileRepository _repository;

  final Rx<ProfileSection> section = ProfileSection.dashboard.obs;
  final Rx<ProfileStats> stats = ProfileStats.empty.obs;

  List<ProfileSection> get sections => ProfileSection.values;

  /// The month the History calendar is showing. The design prints August 2024.
  final Rx<DateTime> month = DateTime(2024, 8).obs;

  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  void selectDate(DateTime date) => selectedDate.value = date;

  /// Mood and Journal open a calendar of past entries; the two daily habits
  /// have their own screen, with a reminder behind it.
  void openCheckin(CheckinKind kind) => Get.toNamed(
        switch (kind) {
          CheckinKind.mood || CheckinKind.journal => AppRoutes.checkin,
          CheckinKind.meditation || CheckinKind.balance => AppRoutes.daily,
        },
        arguments: kind,
      );

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
