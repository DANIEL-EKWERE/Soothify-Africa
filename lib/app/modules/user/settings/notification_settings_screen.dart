import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/notification_preference.dart';
import 'controller/notification_settings_controller.dart';
import 'widgets/settings_header.dart';

/// "Notifications" — Figma `259:37526`.
///
/// Four labelled switches on a 52 pitch, the first at 132, each label against
/// a 246 box with its toggle at the right margin.
class NotificationSettingsScreen
    extends GetView<NotificationSettingsController> {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'Notifications'),
            SizedBox(height: 25.v),
            for (final p in NotificationPreference.values)
              Padding(
                padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 8.v),
                child: SizedBox(
                  height: 44.v,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.label,
                          style: CustomTextStyles.settingsRowLabel,
                        ),
                      ),
                      Obx(
                        () => Switch(
                          value: controller.isOn(p),
                          onChanged: (value) => controller.toggle(p, value),
                          activeTrackColor: appTheme.soothifyBlue,
                          inactiveTrackColor: appTheme.toggleTrack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
