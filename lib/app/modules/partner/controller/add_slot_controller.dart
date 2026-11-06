import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../core/base_controller.dart';
import '../../../data/models/studio_partner.dart';
import '../../../data/repositories/partner_repository.dart';

/// How a slot repeats — the three rows on `416:26557`.
enum SlotRecurrence {
  never('Does Not Repeat'),
  weekdays('Every Weekday'),
  custom('Custom Weekly Schedule');

  const SlotRecurrence(this.label);

  final String label;
}

/// Backs "5.2 · Add Sōōthify class slot" (`416:26557`).
///
/// The sheet puts a Passport class on the studio's timetable. Everything it
/// collects is the studio's own — Soothify only learns how many places are
/// reserved for members.
class AddSlotController extends BaseController {
  AddSlotController(this._repository, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final PartnerRepository _repository;
  final DateTime Function() _now;

  final Rx<StudioClassCategory> category = StudioClassCategory.reformer.obs;
  final title = TextEditingController();
  final instructor = TextEditingController();
  final room = TextEditingController();

  late final Rx<DateTime> day = DateTime(
    _now().year,
    _now().month,
    _now().day,
  ).obs;

  /// Minutes from midnight, so the picker and the grid agree.
  final RxInt startMinute = (16 * 60).obs;
  final RxInt duration = 60.obs;

  /// How many places are held for Passport members, of the class's own
  /// total. The frame draws 3 of 8.
  final RxInt spots = 3.obs;
  static const int classCapacity = 8;

  /// "Gives higher visibility in Sōōthify app feed."
  final RxBool offPeak = true.obs;

  final Rx<SlotRecurrence> recurrence = SlotRecurrence.custom.obs;

  /// Monday-first, as the row is drawn. The frame ships Mon, Wed and Fri.
  final RxList<int> days = <int>[1, 3, 5].obs;

  late final Rx<DateTime> expires = DateTime(_now().year, 12, 31).obs;

  final RxBool saving = false.obs;

  bool get canCreate =>
      title.text.trim().isNotEmpty &&
      instructor.text.trim().isNotEmpty &&
      room.text.trim().isNotEmpty &&
      spots.value > 0;

  /// Nudged on every keystroke, so [canCreate] has something to rebuild on.
  final RxInt edits = 0.obs;

  void touch() => edits.value++;

  void choose(StudioClassCategory value) => category.value = value;

  void repeat(SlotRecurrence value) => recurrence.value = value;

  void toggleDay(int weekday) {
    days.contains(weekday) ? days.remove(weekday) : days.add(weekday);
  }

  /// Bounded by the class's own size: reserving more places than the room
  /// holds is how a member turns up to a full floor.
  void fewer() => spots.value = (spots.value - 1).clamp(0, classCapacity);

  void more() => spots.value = (spots.value + 1).clamp(0, classCapacity);

  String get allocation =>
      '${spots.value} of $classCapacity total class spots reserved';

  /// "Repeats Mon, Wed & Fri until 31 Dec 2026."
  String get recurrenceSummary {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final until = '${expires.value.day} '
        '${const [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ][expires.value.month - 1]} ${expires.value.year}';
    switch (recurrence.value) {
      case SlotRecurrence.never:
        return 'Runs once, on ${day.value.day}/${day.value.month}.';
      case SlotRecurrence.weekdays:
        return 'Repeats every weekday until $until.';
      case SlotRecurrence.custom:
        if (days.isEmpty) return 'Pick the days it repeats on.';
        final chosen = ([...days]..sort()).map((d) => names[d - 1]).toList();
        final last = chosen.removeLast();
        return chosen.isEmpty
            ? 'Repeats $last until $until.'
            : 'Repeats ${chosen.join(', ')} & $last until $until.';
    }
  }

  String get startLabel {
    final hour24 = startMinute.value ~/ 60;
    final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = (startMinute.value % 60).toString().padLeft(2, '0');
    return '$hour:$minute ${hour24 < 12 ? 'AM' : 'PM'}';
  }

  String get durationLabel => '${duration.value} minutes';

  Future<void> create() async {
    if (!canCreate || saving.value) return;
    saving.value = true;
    final added = await guard(
      () => _repository.addSlot(
        StudioClassSlot(
          id: '',
          title: title.text.trim(),
          category: category.value,
          startsAt: day.value.add(Duration(minutes: startMinute.value)),
          minutes: duration.value,
          instructor: instructor.text.trim(),
          room: room.text.trim(),
          passportOpen: spots.value,
          passportTotal: spots.value,
        ),
      ),
      setLoading: false,
    );
    saving.value = false;
    if (added == null) return;
    Get.back(result: added);
    AppFeedback.info('${added.title} is on your schedule.');
  }

  @override
  void onClose() {
    title.dispose();
    instructor.dispose();
    room.dispose();
    super.onClose();
  }
}
