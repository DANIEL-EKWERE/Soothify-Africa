import 'package:intl/intl.dart';

import 'session_offering.dart';

/// A session the user has chosen a time for but not yet paid for.
///
/// The calendar now runs before the payment screen — you pick when, then pay
/// for that — so the choice has to travel: calendar -> payment -> receipt ->
/// confirmation. It used to be the other way round, and nothing needed
/// carrying because the day was picked last.
class BookedSlot {
  const BookedSlot({
    required this.offering,
    required this.day,
    required this.slot,
  });

  final SessionOffering offering;

  /// Midnight on the chosen day; [slot] carries the hour.
  final DateTime day;

  /// One of the calendar's start times, as it prints it — "5:00pm".
  final String slot;

  /// "Monday, 28 September at 5:00pm" — the confirmation's line.
  String get summary =>
      '${DateFormat('EEEE, d MMMM').format(day)} at $slot';

  /// "28 Sep 2026 · 5:00pm" — the compact form the payment screen prints
  /// under its heading, where the sentence above it is already long.
  String get compact => '${DateFormat('d MMM yyyy').format(day)} · $slot';
}
