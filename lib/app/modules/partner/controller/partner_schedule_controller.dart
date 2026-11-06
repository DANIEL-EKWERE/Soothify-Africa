import '../../../core/app_export.dart';
import '../../../core/base_controller.dart';
import '../../../data/models/studio_partner.dart';
import '../../../data/repositories/partner_repository.dart';

/// Day, week or month — the switcher above the grid.
enum ScheduleSpan { day, week, month }

/// Backs "5.1 · Master schedule & Sōōthify slots" (`416:26376`).
class PartnerScheduleController extends BaseController {
  PartnerScheduleController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final PartnerRepository _repository;
  final DateTime Function() _now;

  final Rxn<StudioSchedule> schedule = Rxn<StudioSchedule>();
  final Rx<ScheduleSpan> span = ScheduleSpan.week.obs;

  /// Which week the grid is showing — any day inside it.
  late final Rx<DateTime> anchor = _now().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() => guard(() async =>
      schedule.value = await _repository.schedule(week: anchor.value));

  void show(ScheduleSpan value) => span.value = value;

  Future<void> previousWeek() => _shift(-7);

  Future<void> nextWeek() => _shift(7);

  Future<void> _shift(int days) async {
    anchor.value = anchor.value.add(Duration(days: days));
    await load();
  }

  /// "30 Nov – 6 Dec 2026".
  String get weekLabel {
    final week = schedule.value;
    if (week == null) return '';
    final end = week.weekStart.add(const Duration(days: 6));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${week.weekStart.day} ${months[week.weekStart.month - 1]} – '
        '${end.day} ${months[end.month - 1]} ${end.year}';
  }

  /// The classes on one column of the grid.
  List<StudioClassSlot> on(DateTime day) =>
      (schedule.value?.classes ?? const <StudioClassSlot>[])
          .where((c) =>
              c.startsAt.year == day.year &&
              c.startsAt.month == day.month &&
              c.startsAt.day == day.day)
          .toList();

  void openAddSlot() => Get.toNamed(AppRoutes.partnerAddSlot);
}
