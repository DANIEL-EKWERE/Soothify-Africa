import 'checkin_kind.dart';

/// A habit reminder as the user set it: a time, and the weekdays it repeats.
///
/// Stored, because AlarmManager is not storage. Android cancels every alarm
/// an app owns the moment the app is force-stopped — which is what several
/// OEM launchers do when a user swipes the app away, and what their battery
/// managers do unprompted. Nothing re-created them, so a reminder quietly
/// stopped existing and only came back if the user set it again.
///
/// Held as a flat string rather than JSON: it is two numbers and a day list,
/// and SharedPreferences is the only store this app has.
class HabitReminder {
  const HabitReminder({
    required this.hour,
    required this.minute,
    required this.weekdays,
  });

  final int hour;
  final int minute;

  /// DateTime.monday..DateTime.sunday.
  final Set<int> weekdays;

  bool get isEmpty => weekdays.isEmpty;

  /// "7:5|1,3,5"
  String encode() => '$hour:$minute|${(weekdays.toList()..sort()).join(',')}';

  /// Null for anything unparseable, so a store written by an older build —
  /// or corrupted — is ignored rather than crashing the launch that reads it.
  static HabitReminder? decode(String raw) {
    if (raw.isEmpty) return null;
    final parts = raw.split('|');
    if (parts.length != 2) return null;
    final clock = parts.first.split(':');
    if (clock.length != 2) return null;

    final hour = int.tryParse(clock[0]);
    final minute = int.tryParse(clock[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    final days = parts[1]
        .split(',')
        .map(int.tryParse)
        .whereType<int>()
        .where((d) => d >= DateTime.monday && d <= DateTime.sunday)
        .toSet();
    if (days.isEmpty) return null;

    return HabitReminder(hour: hour, minute: minute, weekdays: days);
  }
}

/// The notification's own words.
///
/// Here rather than on the screen's controller because the app re-arms
/// saved reminders at launch, long before any screen exists — and both
/// paths must produce the same notification.
String reminderTitleFor(CheckinKind kind) => switch (kind) {
      // Not a check-in -- it is a minute of breathing, and calling it one
      // would read as another form to fill in.
      CheckinKind.breathing => 'Time to breathe',
      _ => '${kind.title.replaceFirst('Daily ', '')} Check-In',
    };

String reminderBodyFor(CheckinKind kind) => switch (kind) {
      CheckinKind.breathing =>
        'Sixty seconds to step away from the noise.',
      _ => 'Time for your '
          '${kind.title.replaceFirst('Daily ', '').toLowerCase()} check-in.',
    };
