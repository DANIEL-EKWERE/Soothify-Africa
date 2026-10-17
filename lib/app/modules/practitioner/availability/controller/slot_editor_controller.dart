import '../../../../core/app_export.dart';
import '../../../../data/models/expert_session.dart';
import '../../dashboard/controller/expert_dashboard_controller.dart';

/// Editing one bookable window — Figma "Avaliability" (`259:60077`, the wheel
/// picker) and "Avaliability calendar pop" (`259:60133`, the same screen with
/// a month over it).
class SlotEditorController extends GetxController {
  /// [slot] is injectable so a test can supply one; the route leaves it out
  /// and it comes from the arguments.
  SlotEditorController(this._dashboard, {AvailabilitySlot? slot})
      : slot = slot ??
            (Get.arguments is AvailabilitySlot
                ? Get.arguments as AvailabilitySlot
                : null);

  final ExpertDashboardController _dashboard;

  /// The window being edited. Null when the route was opened without one.
  final AvailabilitySlot? slot;

  late final RxInt hour = ((slot?.from ?? 9 * 60) ~/ 60).obs;
  late final RxInt minute = ((slot?.from ?? 0) % 60).obs;
  late final Rx<DateTime> day = (slot?.day ?? DateTime.now()).obs;

  /// The month the calendar overlay is showing.
  late final Rx<DateTime> month = DateTime(day.value.year, day.value.month).obs;

  /// Which weekdays this window repeats on — `DateTime.monday`..`sunday`.
  ///
  /// The frame draws seven circles under an "Everyday" label and marks none
  /// of them, so the starting set is the slot's own day alone.
  late final RxSet<int> repeatOn = <int>{day.value.weekday}.obs;

  bool get everyday => repeatOn.length == 7;

  /// The frame gives **one** hh:mm picker, not two, so only the start is
  /// chosen here; the window keeps the length it already had. A second picker
  /// is what an end time would need, and the design does not draw one.
  int get durationMinutes {
    final s = slot;
    if (s == null) return 60;
    return s.to - s.from;
  }

  int get from => hour.value * 60 + minute.value;

  int get to => from + durationMinutes;

  void setHour(int value) => hour.value = value;

  void setMinute(int value) => minute.value = value;

  void toggleDay(int weekday) {
    if (!repeatOn.remove(weekday)) repeatOn.add(weekday);
  }

  void toggleEveryday() {
    if (everyday) {
      repeatOn
        ..clear()
        ..add(day.value.weekday);
    } else {
      repeatOn.addAll([for (var d = 1; d <= 7; d++) d]);
    }
  }

  void selectDay(DateTime value) {
    day.value = value;
    month.value = DateTime(value.year, value.month);
    // The picked day is always part of the repeat, or the window it defines
    // would not include itself.
    repeatOn.add(value.weekday);
  }

  void showMonth(DateTime value) => month.value = value;

  /// Writes the window back, and opens it to clients.
  ///
  /// The whole repeat is written, not just the day that was picked: the
  /// frame's weekday circles are what the practitioner chose, and saving one
  /// day of a seven-day repeat would quietly discard the other six.
  ///
  /// The hour is closed and reopened rather than edited, because an hour is
  /// a row the client's calendar reads — and a booked one cannot be moved
  /// out from under the person who booked it, which is why the close is what
  /// fails first.
  Future<void> save() async {
    if (saving.value) return;
    final s = slot;
    if (s == null) {
      Get.back();
      return;
    }

    saving.value = true;
    final done = await _dashboard.rewriteSlot(
      closing: s,
      days: _daysOfTheRepeat(),
      from: from,
      to: to,
    );
    saving.value = false;
    if (!done) return;

    Get.back();
    AppFeedback.info(
      repeatOn.length > 1
          ? 'Saved. Those hours are open to clients.'
          : 'Saved. That hour is open to clients.',
    );
  }

  /// Whether a save is in flight, so the button cannot be pressed twice.
  final RxBool saving = false.obs;

  /// Every date the chosen repeat covers, within the week the picked day
  /// belongs to. A repeat is a weekly pattern in the frame, and a week is
  /// as far ahead as it can be read to mean without inventing a horizon.
  List<DateTime> _daysOfTheRepeat() {
    final picked = day.value;
    final monday = DateTime(picked.year, picked.month, picked.day)
        .subtract(Duration(days: picked.weekday - 1));
    final days = [
      for (final weekday in repeatOn.toList()..sort())
        monday.add(Duration(days: weekday - 1)),
    ];
    return days.isEmpty ? [picked] : days;
  }
}
