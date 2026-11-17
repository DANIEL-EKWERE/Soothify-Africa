import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';
import '../../../data/models/passport_reservation.dart';
import '../../../widgets/soothify_word.dart';
import '../../practitioner/widgets/expert_money.dart' show money;
import 'controller/passport_hub_controller.dart';

/// "Soothify Passport Hub (inside the Plans tab) · Active Plan".
///
/// What the Plans tab becomes once a Passport is held: the plan and what is
/// left of its allowance, then the classes booked against it. The tier
/// ladder is what Plans shows *before* this — there is nothing to choose
/// once one is active.
class PassportHubScreen extends GetView<PassportHubController> {
  const PassportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.passportPage,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.v),
            Row(
              children: [
                SizedBox(width: 8.h),
                InkWell(
                  onTap: Get.back,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(12.h),
                    child: CustomImageView(
                      imagePath: ImageConstant.icBack,
                      height: 24.h,
                      width: 24.h,
                      color: appTheme.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'plans.title'.tr,
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.appBarTitle,
                  ),
                ),
                SizedBox(width: 48.h),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: Obx(
                  () => ListView(
                    padding: EdgeInsets.fromLTRB(24.h, 24.v, 24.h, 32.v),
                    children: [
                      Text('passport.currentPlan'.tr,
                          style: CustomTextStyles.statsHeading),
                      SizedBox(height: 16.v),
                      const _PlanCard(),
                      SizedBox(height: 32.v),
                      Text('passport.upcoming'.tr,
                          style: CustomTextStyles.statsHeading),
                      SizedBox(height: 16.v),
                      if (!controller.hasReservations)
                        const _NothingBooked()
                      else
                        for (final held in controller.reservations) ...[
                          _ReservationCard(held: held),
                          SizedBox(height: 12.v),
                        ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The plan, its balance and what it opens — the frame's one white card.
class _PlanCard extends StatelessWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassportHubController>();
    final plan = controller.membership.value;
    return Container(
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SoothifyText(
                  plan.planName.isEmpty ? 'Soothify Passport' : plan.planName,
                  style: CustomTextStyles.tierName,
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.h, vertical: 6.v),
                decoration: BoxDecoration(
                  color: appTheme.success.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16.h),
                ),
                child: Text(
                  'passport.active'.tr,
                  style: CustomTextStyles.expertCardMeta
                      .copyWith(color: appTheme.success),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.v),
          // The plan's real price, not the frame's figure: a package costs
          // what it costs, and the Hub must not disagree with the charge.
          Text(
            '${money(plan.priceNaira)}/${'passport.month'.tr}',
            style: CustomTextStyles.passportFor,
          ),
          SizedBox(height: 24.v),
          Row(
            children: [
              Expanded(
                child: Text('passport.classBalance'.tr,
                    style: CustomTextStyles.passportFor),
              ),
              Text(controller.balanceLabel,
                  style: CustomTextStyles.statsHeading),
            ],
          ),
          SizedBox(height: 12.v),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.h),
            child: LinearProgressIndicator(
              value: plan.passportProgress,
              minHeight: 10.v,
              backgroundColor: appTheme.cardRim,
              valueColor:
                  AlwaysStoppedAnimation<Color>(appTheme.soothifyBlue),
            ),
          ),
          SizedBox(height: 20.v),
          Row(
            children: [
              Expanded(
                child: Text('passport.renews'.tr,
                    style: CustomTextStyles.passportFor),
              ),
              Text(
                plan.renewsAt == null
                    ? '—'
                    : DateFormat('MMMM d, y').format(plan.renewsAt!),
                style: CustomTextStyles.statsHeading,
              ),
            ],
          ),
          SizedBox(height: 20.v),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: appTheme.soothifyBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: SoothifyText(
              'passport.whatItOpens'.tr,
              style: CustomTextStyles.expertCardMeta,
            ),
          ),
          SizedBox(height: 24.v),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: controller.manage,
              borderRadius: BorderRadius.circular(8.h),
              child: Container(
                height: 52.v,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.h),
                  border: Border.all(color: appTheme.soothifyBlue),
                ),
                child: SoothifyText(
                  'passport.manage'.tr,
                  style: CustomTextStyles.subscribeLabel
                      .copyWith(color: appTheme.soothifyBlue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One booked class, with its two actions.
class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.held});

  final PassportReservation held;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassportHubController>();
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.h),
            child: CustomImageView(
              imagePath: held.cover.isEmpty ? null : held.cover,
              height: 72.h,
              width: 72.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(held.className, style: CustomTextStyles.statsHeading),
                SizedBox(height: 4.v),
                Text(
                  _when(held),
                  style: CustomTextStyles.passportFor,
                ),
                SizedBox(height: 10.v),
                Row(
                  children: [
                    InkWell(
                      onTap: () => controller.openReservation(held),
                      child: Text(
                        'passport.viewDetails'.tr,
                        style: CustomTextStyles.expertSeeAll,
                      ),
                    ),
                    SizedBox(width: 24.h),
                    if (held.canCancel)
                      InkWell(
                        onTap: () => controller.openCancel(held),
                        child: Text(
                          'passport.cancelReservation'.tr,
                          style: CustomTextStyles.expertSeeAll
                              .copyWith(color: appTheme.error),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "Tomorrow, 9:00 AM - 10:00 AM · 1 class", as the frame writes it.
  static String _when(PassportReservation held) {
    final now = DateTime.now();
    final day = DateTime(held.startsAt.year, held.startsAt.month,
        held.startsAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = day.difference(today).inDays;
    final label = switch (difference) {
      0 => 'passport.today'.tr,
      1 => 'passport.tomorrow'.tr,
      _ => DateFormat('EEE, d MMM').format(held.startsAt),
    };
    final from = DateFormat('h:mm a').format(held.startsAt);
    final to = DateFormat('h:mm a')
        .format(held.startsAt.add(const Duration(hours: 1)));
    return '$label, $from - $to · 1 ${'passport.classWord'.tr}';
  }
}

class _NothingBooked extends StatelessWidget {
  const _NothingBooked();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.v, horizontal: 24.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        children: [
          Text(
            'passport.nothingBooked'.tr,
            textAlign: TextAlign.center,
            style: CustomTextStyles.statsHeading,
          ),
          SizedBox(height: 8.v),
          Text(
            'passport.nothingBookedBody'.tr,
            textAlign: TextAlign.center,
            style: CustomTextStyles.passportFor,
          ),
        ],
      ),
    );
  }
}
