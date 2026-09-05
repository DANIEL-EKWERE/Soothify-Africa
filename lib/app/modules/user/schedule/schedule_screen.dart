import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/session_offering.dart';
import 'controller/schedule_controller.dart';

/// Schedule — Figma "Schedule screen" (135:20771).
///
/// Three 342-square cards, each a gradient panel holding cover art, a title,
/// a blurb and a white Book session button.
class ScheduleScreen extends GetView<ScheduleController> {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 32.v),
          children: [
            _Header(),
            SizedBox(height: 51.v),
            Text(
              'Schedule live sessions\nwith experts',
              style: CustomTextStyles.scheduleHeading,
            ),
            SizedBox(height: 24.v),
            for (final offering in controller.offerings) ...[
              _OfferingCard(offering: offering),
              SizedBox(height: 24.v),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
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
            'Schedule',
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
        SizedBox(width: 16.h),
      ],
    );
  }
}

class _OfferingCard extends StatelessWidget {
  const _OfferingCard({required this.offering});

  final SessionOffering offering;

  Gradient _gradient() => switch (offering) {
        SessionOffering.therapy => appTheme.navActiveGradient,
        SessionOffering.meditation => appTheme.meditationSessionGradient,
        SessionOffering.balance => appTheme.balanceSessionGradient,
      };

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ScheduleController>();
    return Container(
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        gradient: _gradient(),
        borderRadius: BorderRadius.circular(16.h),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.h),
            child: CustomImageView(
              imagePath: ImageConstant.imgSessionCover,
              height: 150.v,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16.v),
          Text(
            offering.title,
            style: CustomTextStyles.tierName.copyWith(color: appTheme.onPrimary),
          ),
          SizedBox(height: 4.v),
          Text(
            offering.blurb,
            style: CustomTextStyles.scheduleBlurb,
          ),
          SizedBox(height: 16.v),
          InkWell(
            onTap: () => controller.book(offering),
            borderRadius: BorderRadius.circular(8.h),
            child: Container(
              height: 48.v,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // Fixed white, not surface: the card keeps its gradient in
                // dark mode, so the button must stay light with it.
                color: appTheme.onPrimary,
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: Text(
                'Book session',
                style: CustomTextStyles.statsActionLabel
                    .copyWith(fontSize: 18.fSize),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
