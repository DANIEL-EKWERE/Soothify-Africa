/// The breathing minute, and how many days running.
///
/// The streak lived in the phone's own preferences alone, so forty days of
/// it vanished with the app and never followed anybody to a new handset.
abstract class BreathingRepository {
  /// How many days running, and how much has been done altogether.
  ///
  /// [now] is the caller's own day. The server runs on UTC, so it cannot be
  /// trusted to know which day it is where the phone is.
  Future<BreathingState> state({DateTime? now});

  /// One minute finished. Returns the state it leaves behind.
  Future<BreathingState> recordMinute({int seconds = 60, DateTime? now});
}

/// What the screen shows after a minute.
class BreathingState {
  const BreathingState({this.streak = 0, this.minutes = 0, this.days = 0});

  /// Days running, counting back from today. Yesterday still counts before
  /// today's is done: telling somebody at breakfast that their streak is
  /// zero would be both wrong and discouraging.
  final int streak;

  /// Whole minutes altogether.
  final int minutes;

  /// Distinct days, which is not the same as [streak] once one is broken.
  final int days;

  factory BreathingState.fromJson(Map<String, dynamic> json) => BreathingState(
        streak: json['streak'] as int? ?? 0,
        minutes: json['minutes'] as int? ?? 0,
        days: json['days'] as int? ?? 0,
      );
}
