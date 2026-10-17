import '../../../../core/app_export.dart';
import '../../../../data/models/checkin_kind.dart';
import '../../../../data/models/notification_preference.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../../../data/services/push_service.dart';

/// Backs "Notifications" — Figma `259:37526`.
///
/// The switches persist, and switching one off cancels whatever that habit
/// has scheduled. Setting a reminder switches the matching one on, so the
/// two can never disagree about whether a reminder will arrive.
class NotificationSettingsController extends GetxController {
  NotificationSettingsController(this._notifications);

  final NotificationRepository _notifications;

  final RxMap<NotificationPreference, bool> enabled =
      <NotificationPreference, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // The device's own answer first, so the switches are right on the frame
    // the screen is built with rather than flicking a moment later.
    enabled.assignAll({
      for (final p in NotificationPreference.values)
        p: PrefUtils().notificationPreference(p.key),
    });
    _readFromServer();
  }

  /// The server decides what it sends; this screen only says what was asked
  /// for. Both copies are kept because they answer different questions: the
  /// device schedules its own reminders offline, and the server needs to
  /// know before it sends anything.
  Future<void> _readFromServer() async {
    try {
      final saved = await _notifications.preferences();
      if (saved.isEmpty) return;
      for (final p in NotificationPreference.values) {
        final value = saved[p.key];
        if (value == null) continue;
        enabled[p] = value;
        await PrefUtils().setNotificationPreference(p.key, value);
      }
    } on AppException {
      // Offline, or signed out. The switches still work on the device, and
      // the next change pushes them up.
    }
  }

  bool isOn(NotificationPreference p) => enabled[p] ?? false;

  Future<void> toggle(NotificationPreference p, bool value) async {
    enabled[p] = value;
    await PrefUtils().setNotificationPreference(p.key, value);
    if (!value) await _cancelReminders(p);

    try {
      await _notifications.savePreference(p.key, value);
    } on AppException catch (error) {
      // The switch stays where it was put -- it governs this device's own
      // reminders either way -- but the server has not heard, and a
      // promotional email arriving after it was switched off is exactly
      // what this screen promises will not happen.
      AppFeedback.error(error);
    }
  }

  /// Switching a habit off has to take its scheduled reminders with it —
  /// a cancelled switch and a reminder that still arrives is the worst of
  /// both.
  ///
  /// Promotional offers are sent from the server, so there is nothing
  /// locally scheduled to cancel; turning that one off is for the backend
  /// to honour once the token carries preferences.
  Future<void> _cancelReminders(NotificationPreference p) async {
    if (!Get.isRegistered<PushService>()) return;
    for (final kind in CheckinKind.values) {
      if (preferenceFor(kind) != p) continue;
      await Get.find<PushService>().cancelSeries(reminderSeries(kind));
      // And forget it, or the next launch would re-arm what was just
      // switched off — see PushService.rearmSavedReminders.
      await PrefUtils().clearReminder(kind.name);
    }
  }
}
