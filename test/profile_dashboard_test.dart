import 'package:flutter_test/flutter_test.dart';

import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/models/profile_stats.dart';

/// The Profile dashboard's numbers, as the app reads them.
///
/// Two of the three counters were wrong rather than missing: the minutes
/// were split by category ids the library does not have, and "Live
/// sessions" was a hardcoded zero. Both are now served; these pin what the
/// app does with the answer.
void main() {
  Map<String, dynamic> payload({
    int pilates = 75,
    int balance = 45,
    int done = 120,
    int goal = 150,
    List<int> weekdays = const [1, 2, 3, 4, 5],
    List<Map<String, dynamic>> recent = const [],
  }) =>
      {
        'pilates_minutes': pilates,
        'balance_minutes': balance,
        'meditation_minutes': pilates,
        'live_sessions': 2,
        'active_days': weekdays.length,
        'active_weekdays': weekdays,
        'minutes_done': done,
        'goal_minutes': goal,
        'week_start': '2026-10-05',
        'week_end': '2026-10-11',
        'recent': recent,
      };

  group('the stats', () {
    test('both halves are read apart', () {
      final stats = ProfileStats.fromJson(payload());

      expect(stats.pilatesMinutes, 75);
      expect(stats.balanceMinutes, 45);
      expect(stats.liveSessions, 2);
    });

    test('an older server that only sends the old key still works', () {
      final stats = ProfileStats.fromJson({
        'meditation_minutes': 30,
        'balance_minutes': 10,
        'live_sessions': 0,
      });

      expect(stats.pilatesMinutes, 30);
      // Everything new falls back rather than throwing.
      expect(stats.goalMinutes, 150);
      expect(stats.activeWeekdays, isEmpty);
      expect(stats.recent, isEmpty);
    });

    test('the goal bar and the line left to go', () {
      final stats = ProfileStats.fromJson(payload(done: 120, goal: 150));

      expect(stats.goalProgress, closeTo(0.8, 0.001));
      expect(stats.minutesRemaining, 30);
    });

    test('doing double the goal is met, not two hundred per cent', () {
      final stats = ProfileStats.fromJson(payload(done: 300, goal: 150));

      expect(stats.goalProgress, 1.0);
      expect(stats.minutesRemaining, 0);
    });

    test('a goal of zero does not divide by it', () {
      final stats = ProfileStats.fromJson(payload(goal: 0));

      expect(stats.goalProgress, 0);
    });

    test('the weekday strip carries the days that had something', () {
      final stats = ProfileStats.fromJson(payload(weekdays: [1, 3, 5]));

      expect(stats.activeWeekdays, {1, 3, 5});
      expect(stats.activeWeekdays.contains(7), isFalse);
    });
  });

  group('a recent row', () {
    RecentPlay rowPlayedAt(DateTime when, {int seconds = 1800}) =>
        RecentPlay.fromJson({
          'id': '1',
          'title': 'Feel-good core flow',
          'media_type': 'video',
          'duration_seconds': seconds,
          'played_at': when.toIso8601String(),
        });

    final now = DateTime(2026, 10, 28, 12);

    test('it prints how long ago, finely, for the history log', () {
      expect(
        rowPlayedAt(now.subtract(const Duration(minutes: 30))).agoFor(now),
        '30 min ago',
      );
      expect(
        rowPlayedAt(now.subtract(const Duration(hours: 1))).agoFor(now),
        '1 hour ago',
      );
      expect(
        rowPlayedAt(now.subtract(const Duration(days: 1))).agoFor(now),
        'Yesterday',
      );
    });

    test('it prints the day, coarsely, for the dashboard', () {
      expect(rowPlayedAt(now).whenFor(now), 'Today');
      expect(
        rowPlayedAt(now.subtract(const Duration(days: 1))).whenFor(now),
        'Yesterday',
      );
      expect(
        rowPlayedAt(now.subtract(const Duration(days: 3))).whenFor(now),
        '3 days ago',
      );
    });

    test('a long one is written in hours, not a hundred minutes', () {
      expect(rowPlayedAt(now, seconds: 1800).lengthLabel, '30 min');
      expect(rowPlayedAt(now, seconds: 7200).lengthLabel, '2 hr');
      expect(rowPlayedAt(now, seconds: 5400).lengthLabel, '1 hr 30 min');
      expect(rowPlayedAt(now, seconds: 0).lengthLabel, '');
    });

    test('it carries the item itself, so a row can be opened', () {
      final row = rowPlayedAt(now);

      expect(row.item, isA<MediaItem>());
      expect(row.item.title, 'Feel-good core flow');
    });
  });
}
