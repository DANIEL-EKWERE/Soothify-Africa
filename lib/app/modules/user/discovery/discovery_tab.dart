import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/media_item.dart';
import 'controller/discovery_tab_controller.dart';
import 'widgets/discovery_card.dart';
import 'widgets/subscription_card.dart';

/// Discovery — Figma "Discovery" (135:3363).
///
/// A search field, two horizontal shelves, and the subscription card. The
/// frame carries its own bottom navigation at y=1071; that is skipped here
/// because the shell supplies it.
///
/// Search has four frames of its own in the design (search, search input,
/// searched result, no result) and none are built, so the field is a button
/// that says so rather than a live TextField that goes nowhere.
class DiscoveryTab extends GetView<DiscoveryTabController> {
  const DiscoveryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24.h, 31.v, 24.h, 32.v),
            children: [
              Text(
                'Discovery',
                textAlign: TextAlign.center,
                style: CustomTextStyles.appBarTitle,
              ),
              SizedBox(height: 24.v),
              const _SearchRow(),
              SizedBox(height: 21.v),
              Obx(() => _Shelf(
                    title: 'Recent',
                    items: controller.recent.toList(),
                    onTap: controller.open,
                  )),
              SizedBox(height: 40.v),
              Obx(() => _Shelf(
                    title: 'Popular',
                    items: controller.popular.toList(),
                    onTap: controller.open,
                  )),
              SizedBox(height: 40.v),
              Obx(() => SubscriptionCard(
                    plans: controller.plans.toList(),
                    selectedPlanId: controller.selectedPlanId.value,
                    freeTrial: controller.freeTrial.value,
                    onPlanSelected: controller.selectPlan,
                    onFreeTrialChanged: controller.toggleFreeTrial,
                    onSubscribe: controller.subscribe,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiscoveryTabController>();
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: controller.openSearch,
            borderRadius: BorderRadius.circular(24.h),
            child: Container(
              height: 48.v,
              padding: EdgeInsets.symmetric(horizontal: 15.h),
              decoration: BoxDecoration(
                color: appTheme.surface,
                borderRadius: BorderRadius.circular(24.h),
                border: Border.all(color: appTheme.searchBorder),
              ),
              child: Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.icSearch,
                    height: 18.h,
                    width: 18.h,
                    color: appTheme.textPrimary,
                  ),
                  SizedBox(width: 14.h),
                  // Flexible so a large system text scale shortens the hint
                  // rather than overflowing the field.
                  Flexible(
                    child: Text(
                      'What can we help you find?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.searchHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 19.h),
        InkWell(
          onTap: controller.openFilters,
          child: CustomImageView(
            imagePath: ImageConstant.icFilter,
            height: 19.h,
            width: 25.h,
            color: appTheme.actionFill,
          ),
        ),
      ],
    );
  }
}

class _Shelf extends StatelessWidget {
  const _Shelf({
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<MediaItem> items;
  final ValueChanged<MediaItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CustomTextStyles.sectionTitle),
        SizedBox(height: 16.v),
        SizedBox(
          height: 166.v,
          // Scrolls past the frame edge — the design shows a third card
          // clipped at x=390, so the shelf is meant to run off-screen.
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(width: 20.h),
            itemBuilder: (context, i) => DiscoveryCard(
              item: items[i],
              onTap: () => onTap(items[i]),
            ),
          ),
        ),
      ],
    );
  }
}
