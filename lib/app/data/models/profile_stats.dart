import 'media_item.dart';

/// The Profile dashboard, in one answer — Figma "Profile" (the Dashboard
/// tab).
///
/// More than three counters: the card is headed "This week", there is a goal
/// under it with a weekday strip, and a list of what was actually played.
class ProfileStats {
  const ProfileStats({
    this.pilatesMinutes = 0,
    this.balanceMinutes = 0,
    this.liveSessions = 0,
    this.activeDays = 0,
    this.activeWeekdays = const {},
    this.minutesDone = 0,
    this.goalMinutes = 150,
    this.weekStart,
    this.weekEnd,
    this.recent = const [],
  });

  /// "Pilates & Core minutes" and "Stretch & Restore minutes".
  ///
  /// Split by section — which half of the app a piece sits in — not by
  /// category. Category was what let the rename silently zero the second
  /// one: it counted ids that no longer existed.
  final int pilatesMinutes;
  final int balanceMinutes;

  /// Sessions attended this week. Ones booked for later do not count.
  final int liveSessions;

  /// "5 active days".
  final int activeDays;

  /// Which weekdays this week had something on them, ISO 1 (Mon) to 7 (Sun)
  /// — the M T W T F S S strip.
  final Set<int> activeWeekdays;

  /// "120 / 150 min".
  final int minutesDone;
  final int goalMinutes;

  /// The range the numbers are for — "This week · 5–11 Oct". From the
  /// server, so the heading names the week it actually counted.
  final DateTime? weekStart;
  final DateTime? weekEnd;

  /// "Recent activity". History, not this week's: the rows say "Today" and
  /// "Yesterday".
  final List<RecentPlay> recent;

  /// How far round the goal ring, 0..1. Capped, because somebody who does
  /// double their goal has met it, not 200% of it.
  double get goalProgress => goalMinutes <= 0
      ? 0
      : (minutesDone / goalMinutes).clamp(0.0, 1.0);

  /// "Just 30 more minutes to reach your goal." Zero once it is met.
  int get minutesRemaining =>
      (goalMinutes - minutesDone) < 0 ? 0 : goalMinutes - minutesDone;

  static const ProfileStats empty = ProfileStats();

  /// DRF returns snake_case; these keys match that contract.
  factory ProfileStats.fromJson(Map<String, dynamic> json) => ProfileStats(
        // `meditation_minutes` is the older name for the same number, still
        // served so an older build keeps working.
        pilatesMinutes: json['pilates_minutes'] as int? ??
            json['meditation_minutes'] as int? ??
            0,
        balanceMinutes: json['balance_minutes'] as int? ?? 0,
        liveSessions: json['live_sessions'] as int? ?? 0,
        activeDays: json['active_days'] as int? ?? 0,
        activeWeekdays: {
          for (final day in (json['active_weekdays'] as List? ?? const []))
            if (day is int) day,
        },
        minutesDone: json['minutes_done'] as int? ?? 0,
        goalMinutes: json['goal_minutes'] as int? ?? 150,
        weekStart: DateTime.tryParse('${json['week_start']}'),
        weekEnd: DateTime.tryParse('${json['week_end']}'),
        recent: [
          for (final row in (json['recent'] as List? ?? const []))
            if (row is Map<String, dynamic>) RecentPlay.fromJson(row),
        ],
      );
}

/// One row under "Recent activity": what was played, and when.
class RecentPlay {
  const RecentPlay({required this.item, this.playedAt});

  final MediaItem item;
  final DateTime? playedAt;

  /// "30 min ago", "2 hours ago", "Yesterday" — what the History list
  /// prints above each title. Finer than [whenFor], which the dashboard
  /// uses, because that list is read as a log.
  String agoFor(DateTime now) {
    final at = playedAt;
    if (at == null) return '';
    final since = now.difference(at);
    if (since.inMinutes < 1) return 'Just now';
    if (since.inMinutes < 60) return '${since.inMinutes} min ago';
    if (since.inHours < 24) {
      return since.inHours == 1 ? '1 hour ago' : '${since.inHours} hours ago';
    }
    if (since.inDays == 1) return 'Yesterday';
    return '${since.inDays} days ago';
  }

  /// "30 min", "2 hr", "1 hr 30 min" — the frame writes the longer ones in
  /// hours, and "120 min" reads as a number rather than a length.
  String get lengthLabel {
    final seconds = item.durationSeconds;
    if (seconds <= 0) return '';
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours hr' : '$hours hr $rest min';
  }

  /// "Today", "Yesterday", "3 days ago" — computed, because a stored string
  /// goes stale the moment the screen is opened twice.
  String whenFor(DateTime now) {
    final at = playedAt;
    if (at == null) return '';
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(at.year, at.month, at.day))
        .inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  factory RecentPlay.fromJson(Map<String, dynamic> json) => RecentPlay(
        item: MediaItem.fromJson(json),
        playedAt: DateTime.tryParse('${json['played_at']}')?.toLocal(),
      );
}

/// The Profile screen's three views, in the order the design lays them out.
///
/// Only [dashboard] is built; the design has separate frames for the other
/// two (Profile/history, Profile/mood checkin).
enum ProfileSection {
  dashboard('Dashboard'),
  history('History'),
  checkIns('Check-Ins');

  const ProfileSection(this.label);

  final String label;
}
