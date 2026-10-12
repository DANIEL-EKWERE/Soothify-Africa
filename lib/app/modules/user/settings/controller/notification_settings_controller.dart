import '../../../../core/app_export.dart';
import '../../../../data/models/checkin_kind.dart';
import '../../../../data/models/notification_preference.dart';
import '../../../../data/services/push_service.dart';

/// Backs "Notifications" — Figma `259:37526`.
///
/// The switches persist, and switching one off cancels whatever that habit
/// has scheduled. Setting a reminder switches the matching one on, so the
/// two can never disagree about whether a reminder will arrive.
class NotificationSettingsController extends GetxController {
  final RxMap<NotificationPreference, bool> enabled =
      <NotificationPreference, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    enabled.assignAll({
      for (final p in NotificationPreference.values)
        p: PrefUtils().notificationPreference(p.key),
    });
  }

  bool isOn(NotificationPreference p) => enabled[p] ?? false;

  Future<void> toggle(NotificationPreference p, bool value) async {
    enabled[p] = value;
    await PrefUtils().setNotificationPreference(p.key, value);
    if (!value) await _cancelReminders(p);
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
