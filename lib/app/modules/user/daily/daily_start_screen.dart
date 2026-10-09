import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/media_item.dart';
import '../../../data/repositories/content_repository.dart';
import '../discovery/widgets/discovery_card.dart';
import 'controller/daily_controller.dart';

/// What "Start Daily …" opens: a pair of sessions to begin with, and the
/// offer to make the habit a standing reminder.
///
/// Measured below the status bar: "Recommended for you" at 110, the two
/// cards at 145, a rule at 356, the bell at 404 in a 60 white circle, the
/// heading at 490, the blurb at 528 and the three times from 616 on a 48
/// pitch, each 52 tall.
class DailyStartScreen extends GetView<DailyController> {
  const DailyStartScreen({super.key});

  /// The frame offers three, and they are the reminder's rough hour rather
  /// than a precise time — the next screen sets that.
  static const List<(String, TimeOfDay)> whens = [
    ('Morning', TimeOfDay(hour: 9, minute: 0)),
    ('Afternoon', TimeOfDay(hour: 14, minute: 0)),
    ('Evening', TimeOfDay(hour: 19, minute: 0)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 32.v),
          children: [
            _Header(title: controller.title),
            SizedBox(height: 40.v),
            Text('Recommended for you',
                style: CustomTextStyles.sectionTitle),
            SizedBox(height: 16.v),
            FutureBuilder<List<MediaItem>>(
              future: Get.find<ContentRepository>().getRecommendations(),
              builder: (context, snapshot) {
                final items = (snapshot.data ?? const <MediaItem>[]).take(2);
                if (items.isEmpty) return SizedBox(height: 166.v);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in items) ...[
                      Expanded(
                        child: DiscoveryCard(
                          item: item,
                          width: 159,
                          onTap: () => Get.toNamed(
                            AppRoutes.media,
                            arguments: item,
                          ),
                        ),
                      ),
                      if (item != items.last) SizedBox(width: 16.h),
                    ],
                  ],
                );
              },
            ),
            SizedBox(height: 36.v),
            Divider(color: appTheme.cardRim, height: 1),
            SizedBox(height: 36.v),
            Center(
              child: Container(
                height: 60.h,
                width: 60.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.surface,
                  shape: BoxShape.circle,
                ),
                child: CustomImageView(
                  imagePath: ImageConstant.icBell,
                  height: 26.h,
                  width: 26.h,
                  color: appTheme.brandDeep,
                ),
              ),
            ),
            SizedBox(height: 18.v),
            Text(
              'Set ${controller.title} Reminder',
              textAlign: TextAlign.center,
              style: CustomTextStyles.dailyReminderHeading,
            ),
            SizedBox(height: 12.v),
            Text(
              'Make ${controller.habit} a daily habit to feel the benefits '
              'of this practice. When would you like to check-in next?',
              textAlign: TextAlign.center,
              style: CustomTextStyles.dailyReminderBlurb,
            ),
            SizedBox(height: 28.v),
            for (final (label, at) in whens) ...[
              _When(label: label, onTap: () => controller.chooseWhen(at)),
              SizedBox(height: 12.v),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: Get.back,
          child: CustomImageView(
            imagePath: ImageConstant.icBack,
            height: 18.h,
            width: 18.h,
            color: appTheme.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
        SizedBox(width: 18.h),
      ],
    );
  }
}

/// "Morning" / "Afternoon" / "Evening" — outlined, because choosing one only
/// opens the screen that actually sets the reminder.
class _When extends StatelessWidget {
  const _When({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100.h),
      child: Container(
        height: 52.v,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 48.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(100.h),
          border: Border.all(color: appTheme.actionFill),
        ),
        child: Text(label, style: CustomTextStyles.dailyWhenLabel),
      ),
    );
  }
}
