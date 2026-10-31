import '../../core/network/api_client.dart';
import '../models/checkin_kind.dart';
import '../models/habit_reminder.dart';
import 'reminder_repository.dart';

/// Reminders against `/api/v1/wellbeing/reminders/`.
class ApiReminderRepository implements ReminderRepository {
  ApiReminderRepository(this._api);

  final ApiClient _api;

  static const _path = '/wellbeing/reminders/';

  @override
  Future<void> save(
    CheckinKind habit,
    HabitReminder reminder, {
    required int utcOffsetMinutes,
  }) =>
      _api.put(_path, body: {
        'habit': habit.name,
        'hour': reminder.hour,
        'minute': reminder.minute,
        'utc_offset_minutes': utcOffsetMinutes,
        'weekdays': (reminder.weekdays.toList()..sort()),
        'is_active': true,
      });

  @override
  Future<void> remove(CheckinKind habit) =>
      _api.delete('$_path?habit=${habit.name}');

  @override
  Future<Map<CheckinKind, HabitReminder>> mine() async {
    final rows = await _api.getList(_path);

    final found = <CheckinKind, HabitReminder>{};
    for (final row in rows) {
      final habit = _habitFor(row['habit'] as String? ?? '');
      if (habit == null) continue;
      if (row['is_active'] == false) continue;

      final days = <int>{
        for (final day in (row['weekdays'] as List? ?? const []))
          if (day is int) day,
      };
      if (days.isEmpty) continue;

      found[habit] = HabitReminder(
        hour: row['hour'] as int? ?? 9,
        minute: row['minute'] as int? ?? 0,
        weekdays: days,
      );
    }
    return found;
  }

  /// A habit the server knows and this app does not is skipped rather
  /// than guessed at.
  static CheckinKind? _habitFor(String name) {
    for (final kind in CheckinKind.values) {
      if (kind.name == name) return kind;
    }
    return null;
  }
}
