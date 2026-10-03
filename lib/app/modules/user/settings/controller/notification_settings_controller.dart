import '../../../../core/app_export.dart';
import '../../../../data/models/notification_preference.dart';

/// Backs "Notifications" — Figma `259:37526`.
///
/// The switches persist. Nothing schedules a reminder yet, so what they
/// currently decide is only what the app will send once something does — but
/// a switch that forgets its position as soon as the screen closes is worse
/// than one that is not wired to delivery.
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
  }
}
