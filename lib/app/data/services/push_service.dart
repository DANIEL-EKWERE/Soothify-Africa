import 'dart:convert';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/app_export.dart';
import '../../../firebase_options.dart';
import '../models/checkin_kind.dart';
import '../models/habit_reminder.dart';
import '../models/notification_preference.dart';
import '../models/push_message.dart';
import '../repositories/device_token_repository.dart';

/// The block of notification ids a habit's reminders live in.
///
/// 100 apart, so a habit's seven weekdays can never collide with another's:
/// re-setting Pilates & Core must replace only its own, and switching a
/// habit off in Settings must cancel only its own.
int reminderSeries(CheckinKind kind) => 1000 + kind.index * 100;

/// The Settings switch that governs a habit's reminders, where there is one.
///
/// Journal has no switch in the frame, so it has no entry here — setting a
/// journal reminder turns nothing on and nothing can switch it off.
NotificationPreference? preferenceFor(CheckinKind kind) => switch (kind) {
  CheckinKind.meditation => NotificationPreference.meditation,
  CheckinKind.balance => NotificationPreference.balance,
  CheckinKind.mood => NotificationPreference.mood,
  CheckinKind.journal => null,
};

/// The channel a push lands on. Declared once and created at startup,
/// because Android fixes a channel's importance the first time it sees it —
/// changing it later in code does nothing until the app is reinstalled.
const _pushChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'Session & reminder alerts',
  description: 'Sessions starting, breathing minutes and habit reminders.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

/// A second channel for what the app schedules itself, so a user can silence
/// their own habit reminders without also silencing a session that is about
/// to start.
const _reminderChannel = AndroidNotificationChannel(
  'soothify_reminders',
  'Daily habit reminders',
  description: 'The check-in reminders you set yourself.',
  importance: Importance.high,
  playSound: true,
);

/// The small status-bar icon. Android silhouettes it, so it has to be the
/// white-on-transparent drawable rather than the launcher icon — a launcher
/// icon shows up as a solid white square.
const _icon = '@drawable/ic_notification';

NotificationDetails _detailsFor(AndroidNotificationChannel channel) =>
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: 'ic_notification',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

/// Draws a push that arrived while the app was not in the foreground.
///
/// Top-level and annotated because Android runs it in its own isolate, with
/// none of the app's state: Firebase has to be started again here, and so
/// does the notifications plugin.
@pragma('vm:entry-point')
Future<void> soothifyBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notification = message.notification;
  // A message with its own `notification` block is drawn by the system
  // already; drawing it again here would show it twice. Only a data-only
  // push needs us.
  if (notification != null) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings(_icon),
    ),
  );
  await plugin.show(
    id: message.hashCode,
    title: (message.data['title'] as String?) ?? 'Soothify',
    body: (message.data['body'] as String?) ?? '',
    notificationDetails: _detailsFor(_pushChannel),
    payload: jsonEncode(message.data),
  );
}

/// Handles a tap that arrives while the app is not running.
@pragma('vm:entry-point')
void soothifyNotificationTapBackground(NotificationResponse response) {
  // Nothing to navigate: there is no engine yet. The tap relaunches the app,
  // and [PushService.start] picks the destination up from the launch
  // notification instead.
}

/// The part of [PushService] a habit screen needs.
///
/// An interface so a controller can be handed a recording fake: the service
/// itself cannot be built in a test, because constructing it reaches for
/// `FirebaseMessaging.instance`.
abstract class ReminderScheduler {
  Future<void> scheduleWeekly({
    required int series,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required Set<int> weekdays,
    PushTopic topic,
    Map<String, String> data,
  });

  Future<void> cancelSeries(int series);
}

/// Push notifications, and the reminders the app schedules for itself.
///
/// Split in two on purpose. [init] is synchronous-ish local work that must
/// finish before anything can be shown — the timezone database, the plugin,
/// the channels — and is awaited in `main`. [start] asks for permission and
/// fetches a token, which are network calls that can hang for tens of
/// seconds; it runs after `runApp` so a slow or captive network cannot hold
/// the splash screen hostage.
class PushService extends GetxService implements ReminderScheduler {
  PushService(this._tokens, {FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final DeviceTokenRepository _tokens;
  final FirebaseMessaging _messaging;

  final plugin = FlutterLocalNotificationsPlugin();

  /// Set once a tap has been handled before the app was ready to navigate —
  /// a cold start from a notification arrives long before the first route.
  PushDestination? _pending;

  bool _ready = false;

  Future<PushService> init() async {
    tzdata.initializeTimeZones();
    try {
      tz.setLocalLocation(
        tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier),
      );
    } catch (e) {
      // An unknown zone must not stop the app from starting; reminders then
      // run on UTC, which is wrong by the offset but still fires.
      Log.e('Could not resolve the local timezone', error: e);
    }

    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
        // All three false: asking here would raise the iOS dialog during
        // startup, before the user has seen what the app is for. [start]
        // asks once, through Firebase.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) => _openPayload(r.payload),
      onDidReceiveBackgroundNotificationResponse:
          soothifyNotificationTapBackground,
    );

    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_pushChannel);
    await android?.createNotificationChannel(_reminderChannel);

    _ready = true;
    return this;
  }

  /// Re-arms every saved reminder, replacing whatever AlarmManager still
  /// holds.
  ///
  /// Android cancels an app's alarms when it is force-stopped, and several
  /// OEM launchers force-stop an app the moment it is swiped off the recents
  /// list. The alarm is simply gone, and no broadcast says so — which is why
  /// a reminder appeared to work only while the app was running. The store
  /// is the record; AlarmManager is a cache of it, rebuilt on every launch.
  ///
  /// Idempotent: [scheduleWeekly] cancels the habit's series before laying
  /// it down again, so running this when the alarms are still healthy
  /// changes nothing.
  Future<void> rearmSavedReminders() async {
    for (final kind in CheckinKind.values) {
      final saved = HabitReminder.decode(PrefUtils().reminder(kind.name));
      if (saved == null) continue;

      // A habit switched off in Settings must not come back at launch.
      final preference = preferenceFor(kind);
      if (preference != null &&
          !PrefUtils().notificationPreference(preference.key)) {
        continue;
      }

      await scheduleWeekly(
        series: reminderSeries(kind),
        title: reminderTitleFor(kind),
        body: reminderBodyFor(kind),
        hour: saved.hour,
        minute: saved.minute,
        weekdays: saved.weekdays,
        data: {'habit': kind.name},
      );
    }
  }

  /// Permission, token and listeners. Never awaited by `main`.
  Future<void> start() async {
    // First, and outside the try below: this is local work that must happen
    // whether or not push permission is granted or the network answers.
    try {
      await rearmSavedReminders();
    } catch (e, s) {
      Log.e('Could not re-arm saved reminders', error: e, stackTrace: s);
    }

    try {
      FirebaseMessaging.onMessage.listen(_showForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => _open(destinationFor(m.data)),
      );
      _messaging.onTokenRefresh.listen(_registerToken);

      // A tap that launched the app from cold. It has to be read before
      // anything else, and it is only ever delivered once.
      final launch = await _messaging.getInitialMessage();
      if (launch != null) _open(destinationFor(launch.data));

      if (!kIsWeb && Platform.isAndroid) {
        await plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }

      final settings = await _messaging.requestPermission();
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!granted) {
        Log.d('Notification permission: ${settings.authorizationStatus}');
        return;
      }

      // On iOS the FCM token cannot be minted before APNs has handed one
      // over, which never happens on the simulator. Asking anyway returns an
      // error rather than null, so check first.
      if (!kIsWeb && Platform.isIOS && await _messaging.getAPNSToken() == null) {
        Log.d('APNs has not issued a token yet; skipping the FCM fetch.');
        return;
      }

      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 20),
        onTimeout: () => null,
      );
      if (token != null) await _registerToken(token);
    } catch (e, s) {
      // Push is not load-bearing: the app works without it, so a failure
      // here is logged and swallowed rather than thrown into startup.
      Log.e('Push setup failed', error: e, stackTrace: s);
    }
  }

  // ---- Delivery -----------------------------------------------------------

  /// FCM shows nothing while the app is in the foreground — that is the
  /// platform's behaviour, not a bug — so the notification is drawn here.
  Future<void> _showForeground(RemoteMessage message) async {
    final n = message.notification;
    await plugin.show(
      id: message.hashCode,
      title: n?.title ?? (message.data['title'] as String?) ?? 'Soothify',
      body: n?.body ?? (message.data['body'] as String?) ?? '',
      notificationDetails: _detailsFor(_pushChannel),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _registerToken(String token) async {
    if (token == _tokens.lastRegistered) return;
    final info = DeviceInfoPlugin();
    var model = 'unknown';
    var version = 'unknown';
    if (!kIsWeb && Platform.isAndroid) {
      final a = await info.androidInfo;
      model = a.model;
      version = a.version.release;
    } else if (!kIsWeb && Platform.isIOS) {
      final i = await info.iosInfo;
      model = i.utsname.machine;
      version = i.systemVersion;
    }
    await _tokens.register(
      token: token,
      // Lowercase: PushDevice.PLATFORMS is ('android', 'ios', 'web'), and
      // DRF rejects anything else with a 400.
      platform: !kIsWeb && Platform.isIOS ? 'ios' : 'android',
      deviceModel: model,
      appVersion: version,
    );
  }

  // ---- Reminders ----------------------------------------------------------

  /// Schedules one weekly-repeating reminder per chosen day.
  ///
  /// [series] separates one habit's reminders from another's — see
  /// [reminderSeries]. Ids are `series + weekday`, so re-setting one habit
  /// replaces only its own seven.
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
    if (!_ready) return;
    await cancelSeries(series);
    final mode = await _scheduleMode();
    for (final day in weekdays) {
      await plugin.zonedSchedule(
        id: series + day,
        title: title,
        body: body,
        scheduledDate: nextOccurrence(day, hour, minute),
        notificationDetails: _detailsFor(_reminderChannel),
        androidScheduleMode: mode,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: jsonEncode({'type': topic.wire, ...data}),
      );
    }
  }

  /// Exact if the user has allowed it, inexact otherwise.
  ///
  /// A reminder set for 9:00 should arrive at 9:00, so the app asks for the
  /// exact-alarm permission once. Android 14 throws rather than degrading if
  /// an exact alarm is scheduled without it, so a refusal has to be answered
  /// with the inexact mode — a reminder within the hour beats no reminder,
  /// and beats a crash on the Set button.
  Future<AndroidScheduleMode> _scheduleMode() async {
    if (kIsWeb || !Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    try {
      var allowed = await android?.canScheduleExactNotifications() ?? false;
      if (!allowed) {
        allowed = await android?.requestExactAlarmsPermission() ?? false;
      }
      return allowed
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (e) {
      Log.e('Could not read the exact-alarm permission', error: e);
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  @override
  Future<void> cancelSeries(int series) async {
    if (!_ready) return;
    for (var day = DateTime.monday; day <= DateTime.sunday; day++) {
      await plugin.cancel(id: series + day);
    }
  }

  /// The next [weekday] at [hour]:[minute] in the user's own zone.
  ///
  /// Walks forward a day at a time rather than doing the arithmetic, because
  /// adding a fixed number of days across a DST boundary lands on the wrong
  /// hour; `TZDateTime` re-resolves the offset on each step.
  static tz.TZDateTime nextOccurrence(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (at.weekday != weekday || !at.isAfter(now)) {
      at = at.add(const Duration(days: 1));
    }
    return at;
  }

  // ---- Routing ------------------------------------------------------------

  void _openPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _open(destinationFor(data));
    } catch (e) {
      Log.e('Unreadable notification payload: $payload', error: e);
    }
  }

  void _open(PushDestination destination) {
    // A tap from a cold start beats the first route onto the screen, and
    // pushing onto a navigator that is about to be replaced by the splash's
    // own hand-off loses it. Hold it instead.
    if (Get.key.currentState == null || Get.currentRoute == AppRoutes.splash) {
      _pending = destination;
      return;
    }
    Get.toNamed(destination.route, arguments: destination.arguments);
  }

  /// Opens whatever a cold-start tap asked for. Called once the app has a
  /// screen that can be pushed onto — see `SplashController`.
  void openPending() {
    final destination = _pending;
    if (destination == null) return;
    _pending = null;
    Get.toNamed(destination.route, arguments: destination.arguments);
  }

  /// Whether a tap is still waiting to be acted on. Exposed for the splash,
  /// which skips its usual hand-off when there is one.
  bool get hasPending => _pending != null;
}
