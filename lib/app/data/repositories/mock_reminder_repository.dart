import '../models/checkin_kind.dart';
import '../models/habit_reminder.dart';
import 'reminder_repository.dart';

/// Reminders with no server behind them.
///
/// Kept in memory rather than refusing: the build with no backend still
/// has to let somebody set a reminder, and the local alarm is what
/// actually delivers it there.
class MockReminderRepository implements ReminderRepository {
  final Map<CheckinKind, HabitReminder> _set = {};

  @override
  Future<void> save(
    CheckinKind habit,
    HabitReminder reminder, {
    required int utcOffsetMinutes,
  }) async =>
      _set[habit] = reminder;

  @override
  Future<void> remove(CheckinKind habit) async => _set.remove(habit);

  @override
  Future<Map<CheckinKind, HabitReminder>> mine() async => Map.of(_set);
}
