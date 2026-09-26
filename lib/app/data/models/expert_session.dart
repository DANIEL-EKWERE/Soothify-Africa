import '../../core/utils/image_constant.dart';

/// A booked session, seen from the expert's side — Figma "Expert dashboard"
/// (`259:59239`) and "Upcoming sessions" (`259:59662`).
///
/// The same card carries it in both: the client's name, what was booked, when
/// it runs, and one action.
class ExpertSession {
  const ExpertSession({
    required this.id,
    required this.clientName,
    required this.service,
    required this.startsAt,
    required this.endsAt,
    this.avatarAsset = ImageConstant.imgAvatarFemale,
  });

  final String id;
  final String clientName;

  /// "1-on-1 Therapy", "Pilates".
  final String service;

  final DateTime startsAt;
  final DateTime endsAt;

  final String avatarAsset;

  /// The frame prints every row as "Today, 10:00 AM - 10:30 AM". Composed
  /// from the real times rather than stored, so tomorrow's session does not
  /// also claim to be today.
  String when(DateTime now) {
    final day = DateTime(startsAt.year, startsAt.month, startsAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = day.difference(today).inDays;
    final label = switch (diff) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => '${_month(startsAt.month)} ${startsAt.day}',
    };
    return '$label, ${_clock(startsAt)} - ${_clock(endsAt)}';
  }

  static String _clock(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  static String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m - 1];
}

/// One slot the expert is bookable in — Figma "Avaliability" (`259:59921`).
///
/// The frame's own rows all read "Monday / Sep 28 / 9am - 10 am", repeated
/// five times, so only the shape is taken from it.
class AvailabilitySlot {
  const AvailabilitySlot({
    required this.id,
    required this.day,
    required this.from,
    required this.to,
  });

  final String id;
  final DateTime day;

  /// Minutes from midnight, so a slot is comparable and sortable without a
  /// date attached.
  final int from;
  final int to;

  String get weekday => const [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday',
        'Friday', 'Saturday', 'Sunday',
      ][day.weekday - 1];

  String get date => '${ExpertSession._month(day.month)} ${day.day}';

  String get range => '${_label(from)} - ${_label(to)}';

  static String _label(int minutes) {
    final h24 = minutes ~/ 60;
    final m = minutes % 60;
    final h = h24 % 12 == 0 ? 12 : h24 % 12;
    final suffix = h24 < 12 ? 'am' : 'pm';
    return m == 0 ? '$h$suffix' : '$h:${m.toString().padLeft(2, '0')}$suffix';
  }
}
