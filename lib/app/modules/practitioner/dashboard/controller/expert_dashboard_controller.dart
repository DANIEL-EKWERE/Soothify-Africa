import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/expert_earnings.dart';
import '../../../../data/models/expert_session.dart';
import '../../../../data/models/expert_tab.dart';
import '../../../../data/repositories/expert_repository.dart';
import '../../shell/controller/expert_shell_controller.dart';

/// Backs every tab of the expert role.
///
/// One controller rather than five: the dashboard, Schedule, Earnings and
/// Notes all read the same two lists, and splitting them would mean fetching
/// the same sessions four times and letting the copies drift.
class ExpertDashboardController extends BaseController {
  ExpertDashboardController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final ExpertRepository _repository;
  final DateTime Function() _now;

  final RxString name = ''.obs;
  final RxList<ExpertSession> sessions = <ExpertSession>[].obs;
  final Rxn<ExpertEarnings> earnings = Rxn<ExpertEarnings>();
  final RxList<AvailabilitySlot> slots = <AvailabilitySlot>[].obs;

  DateTime get now => _now();

  /// The dashboard previews three; Schedule lists them all.
  List<ExpertSession> get preview => sessions.take(3).toList();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async {
        final results = await Future.wait([
          _repository.displayName(),
          _repository.upcomingSessions(),
          _repository.earnings(),
          _repository.availability(),
        ]);
        name.value = results[0] as String;
        sessions.assignAll(results[1] as List<ExpertSession>);
        earnings.value = results[2] as ExpertEarnings;
        slots.assignAll(results[3] as List<AvailabilitySlot>);
      });

  void seeAllSessions() =>
      Get.find<ExpertShellController>().show(ExpertTab.schedule);

  void openEarnings() =>
      Get.find<ExpertShellController>().show(ExpertTab.earnings);

  void openAvailability() => Get.toNamed(AppRoutes.expertAvailability);

  /// Opens or closes a slot to booking. Local only — nothing persists
  /// availability yet — but the switch has to move when it is pressed.
  void toggleSlot(AvailabilitySlot slot) {
    final i = slots.indexWhere((s) => s.id == slot.id);
    if (i < 0) return;
    slots[i] = slot.copyWith(enabled: !slot.enabled);
  }

  /// The Quick Action, and the Notes tab's rows. Notes are written per
  /// session, so one has to be chosen first — the frame is titled "Dami's
  /// session notes".
  void openNotes(ExpertSession session) =>
      Get.toNamed(AppRoutes.expertSessionNotes, arguments: session);

  void openSessionNotes() {
    if (sessions.isEmpty) return;
    openNotes(sessions.first);
  }

  /// The pre-call screen — `259:59996`. No call service is wired behind it
  /// on either side; the screen is the connecting state the design draws.
  void joinCall(ExpertSession session) =>
      Get.toNamed(AppRoutes.expertJoinSession, arguments: session);

  /// The bell. A note here used to claim the expert `Notification` frame was
  /// a client screen filed in the wrong row, read off its nav bar; the live
  /// file draws it with the expert's own bar, so it is this role's.
  void openNotifications() => Get.toNamed(AppRoutes.expertNotifications);
}
