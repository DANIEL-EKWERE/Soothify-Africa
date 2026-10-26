import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/checkin_kind.dart';
import 'package:soothifyafrica/app/data/models/habit_reminder.dart';
import 'package:soothifyafrica/app/data/models/push_message.dart';
import 'package:soothifyafrica/app/data/services/push_service.dart';
import 'package:soothifyafrica/app/modules/user/daily/controller/daily_controller.dart';

/// Takes the place of the real scheduler.
class _RecordingScheduler implements ReminderScheduler {
  int? series;
  String? title;
  String? body;
  Set<int>? weekdays;
  Map<String, String>? data;
  final cancelled = <int>[];

  @override
  Future<void> scheduleWeekly({
    required int series,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required Set<int> weekdays,
    PushTopic topic = PushTopic.daily,
    Map<String, String> data = const {},
  }) async {
    this.series = series;
    this.title = title;
    this.body = body;
    this.weekdays = weekdays;
    this.data = data;
  }

  @override
  Future<void> cancelSeries(int series) async => cancelled.add(series);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefUtils.resetForTesting();
    await PrefUtils().init();
    Get.testMode = true;
  });

  tearDown(Get.reset);

  test('the breathing minute can be scheduled like any other habit', () async {
    final scheduler = _RecordingScheduler();
    final controller = DailyController(
      CheckinKind.breathing,
      scheduler: scheduler,
    )
      ..setTime(const TimeOfDay(hour: 7, minute: 30))
      ..toggleDay(DateTime.monday)
      ..toggleDay(DateTime.thursday);

    await controller.setReminder();

    final saved = HabitReminder.decode(
      PrefUtils().reminder(CheckinKind.breathing.name),
    );
    expect(saved, isNotNull);
    expect(saved!.hour, 7);
    expect(saved.minute, 30);
    expect(saved.weekdays, {DateTime.monday, DateTime.thursday});
  });

  test('it is stored under its own series, not another habit\'s', () {
    // Ids are series + weekday, so two habits sharing a series would
    // cancel each other's alarms.
    final series = {
      for (final kind in CheckinKind.values) kind: reminderSeries(kind),
    };
    expect(series.values.toSet().length, CheckinKind.values.length);
  });

  test('the notification does not call it a check-in', () {
    // "Breathing Check-In" reads as another form to fill in.
    expect(reminderTitleFor(CheckinKind.breathing), 'Time to breathe');
    expect(
      reminderBodyFor(CheckinKind.breathing),
      'Sixty seconds to step away from the noise.',
    );
    // The other habits keep the wording the frames use.
    expect(
      reminderTitleFor(CheckinKind.meditation),
      'Pilates & Core Check-In',
    );
  });

  test('a saved breathing reminder survives a relaunch', () async {
    // Android drops every alarm an app owns when it is force-stopped, so
    // the store is the record and the alarms are rebuilt from it.
    await PrefUtils().setReminder(
      CheckinKind.breathing.name,
      const HabitReminder(hour: 6, minute: 15, weekdays: {DateTime.friday})
          .encode(),
    );

    final saved = HabitReminder.decode(
      PrefUtils().reminder(CheckinKind.breathing.name),
    );

    expect(saved?.hour, 6);
    expect(saved?.weekdays, {DateTime.friday});
    // rearmSavedReminders walks CheckinKind.values, so breathing is picked
    // up by the same loop as the rest.
    expect(CheckinKind.values, contains(CheckinKind.breathing));
  });

  test('the screen opens on the reminder already set', () async {
    await PrefUtils().setReminder(
      CheckinKind.breathing.name,
      const HabitReminder(hour: 21, minute: 0, weekdays: {DateTime.sunday})
          .encode(),
    );

    final controller = DailyController(
      CheckinKind.breathing,
      scheduler: _RecordingScheduler(),
    )..onInit();

    expect(controller.reminderAt.value.hour, 21);
    expect(controller.reminderDays, {DateTime.sunday});
  });
}
