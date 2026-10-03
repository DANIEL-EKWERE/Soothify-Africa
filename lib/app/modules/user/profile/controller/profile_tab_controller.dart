
import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/app_tab.dart';
import '../../../../data/models/checkin_kind.dart';
import '../../../../data/models/profile_stats.dart';
import '../../../../data/services/session_service.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../../shell/controller/shell_controller.dart';

/// Backs the Profile tab — Figma "Profile/dashboard" (135:8098).
class ProfileTabController extends BaseController {
  ProfileTabController(this._repository, this._session);

  final SessionService _session;

  /// Browsing without an account — Profile offers sign-up instead of stats.
  bool get isGuest => _session.isGuest;

  /// "Unlock Soothify Pro" on the guest card.
  ///
  /// It used to call `toNamed(shell)` — pushing a second copy of the shell
  /// the user was already inside, which looked like nothing happening. Plans
  /// is a tab, so the way to it is the shell's own selection.
  void openPlans() {
    if (Get.isRegistered<ShellController>()) {
      Get.find<ShellController>().current.value = AppTab.plans;
      return;
    }
    Get.toNamed(AppRoutes.shell);
  }

  final ProfileRepository _repository;

  final Rx<ProfileSection> section = ProfileSection.dashboard.obs;
  final Rx<ProfileStats> stats = ProfileStats.empty.obs;

  List<ProfileSection> get sections => ProfileSection.values;

  /// The month the History calendar is showing. The design prints August 2024.
  final Rx<DateTime> month = DateTime(2024, 8).obs;

  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  void selectDate(DateTime date) => selectedDate.value = date;

  /// Mood opens a calendar of past check-ins; the two daily habits have their
  /// own screen, with a reminder behind it.
  ///
  /// Journal opens the Journal itself. Its `Profile/journal checkin` frames
  /// turn out to be pixel-identical to the `Journal` ones — the two rows are
  /// the same screens under two names — and the check-in calendar had nothing
  /// to draw for this kind, so it was a permanently empty month. This is also
  /// the only way into the Journal: nothing else routed to it.
  void openCheckin(CheckinKind kind) => Get.toNamed(
        switch (kind) {
          CheckinKind.mood => AppRoutes.checkin,
          CheckinKind.journal => AppRoutes.journal,
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
