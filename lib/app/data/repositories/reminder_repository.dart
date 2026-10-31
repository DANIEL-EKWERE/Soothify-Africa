import '../models/checkin_kind.dart';
import '../models/habit_reminder.dart';

/// Habit reminders kept on the account rather than on the phone.
///
/// Local alarms were the whole of it, and two things were wrong with that.
/// Android drops every alarm an app owns when it is force-stopped — which
/// several OEM launchers do when the app is swiped away — and a local
/// notification leaves no row in the in-app feed, so one dismissed from
/// the tray was gone for good.
abstract class ReminderRepository {
  /// Sets or replaces this habit's reminder.
  ///
  /// The offset travels with it: the server runs on UTC and "9:00" means
  /// nine where the person is, not where the server is.
  Future<void> save(
    CheckinKind habit,
    HabitReminder reminder, {
    required int utcOffsetMinutes,
  });

  /// Turns one off.
  Future<void> remove(CheckinKind habit);

  /// What the account has set, by habit. Empty when nothing is.
  Future<Map<CheckinKind, HabitReminder>> mine();
}
