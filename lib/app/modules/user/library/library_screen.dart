import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/library_section.dart';
import '../../../data/models/media_item.dart';
import '../discovery/widgets/discovery_card.dart';
import 'controller/library_controller.dart';

/// Meditation and Balance — Figma 135:11744 and 135:20551.
///
/// Structurally the same frame: a search field, then shelves of cover cards
/// under a heading with a See All link. The card itself is the Discovery card,
/// which the two frames reuse verbatim.
class LibraryScreen extends GetView<LibraryController> {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 32.v),
            children: [
              _Header(title: controller.section.title),
              SizedBox(height: 27.v),
              const _SearchRow(),
              SizedBox(height: 27.v),
              // Rendered in the frame's own order: the blocks are not all
              // shelves, and Meditation interleaves a card between two of them.
              Obx(() => Column(
                    children: [
                      for (final block in controller.section.blocks) ...[
                        switch (block) {
                          LibraryShelf() => _Shelf(
                              title: block.title,
                              items: controller.shelves[block.title] ??
                                  const [],
                            ),
                          LibraryFeature() => _FeatureCard(block: block),
                          LibraryPromo() => _PromoCard(block: block),
                        },
                        SizedBox(height: 32.v),
                      ],
                    ],
                  )),
            ],
          ),
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
        // The design puts a filter glyph here; artwork was not exported.
        // The section's own art, matching its Explore tile on Home.
        CustomImageView(
          imagePath: Get.find<LibraryController>().section.artPath,
          height: 28.h,
          width: 28.h,
        ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LibraryController>();
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
                  Flexible(
                    child: Text(
                      controller.section.searchHint,
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
        SizedBox(width: 28.h),
        // The real filter — it had no action at all.
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
  const _Shelf({required this.title, required this.items});

  final String title;
  final List<MediaItem> items;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LibraryController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.shelfHeading,
              ),
            ),
            InkWell(
              onTap: () => controller.openShelf(title),
              child: Text('See All', style: CustomTextStyles.seeAll),
            ),
          ],
        ),
        SizedBox(height: 16.v),
        SizedBox(
          height: 166.v,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(width: 20.h),
            itemBuilder: (context, i) => DiscoveryCard(
              item: items[i],
              onTap: () => controller.open(items[i]),
            ),
          ),
        ),
      ],
    );
  }
}

/// The Sleep Stories block — a section heading over one wide card.
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.block});

  final LibraryFeature block;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LibraryController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(block.heading, style: CustomTextStyles.shelfHeading),
        SizedBox(height: 16.v),
        InkWell(
          onTap: () => controller.openShelf(block.heading),
          borderRadius: BorderRadius.circular(12.h),
          child: Container(
            height: 122.v,
            padding: EdgeInsets.symmetric(horizontal: 12.h),
            decoration: BoxDecoration(
              color: appTheme.surface,
              borderRadius: BorderRadius.circular(12.h),
              // #000000 at 5% — at full strength this draws a black box.
              border: Border.all(color: appTheme.cardBorder),
            ),
            child: Row(
              children: [
                CustomImageView(
                  imagePath: block.asset,
                  height: 92.h,
                  width: 92.h,
                  radius: BorderRadius.circular(6.h),
                ),
                SizedBox(width: 16.h),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(block.title, style: CustomTextStyles.featureTitle),
                      SizedBox(height: 2.v),
                      Text(block.body, style: CustomTextStyles.featureBody),
                    ],
                  ),
                ),
                SizedBox(width: 9.h),
                CustomImageView(
                  imagePath: ImageConstant.icArrowRight,
                  height: 16.h,
                  width: 16.h,
                  color: appTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The closing sessions promo. No heading, smaller icon, radius 8.
class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.block});

  final LibraryPromo block;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LibraryController>();
    return InkWell(
      onTap: controller.openSessions,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 122.v,
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.cardBorder),
        ),
        child: Row(
          children: [
            CustomImageView(
              imagePath: block.asset,
              height: block.iconSize.h,
              width: block.iconSize.h,
            ),
            SizedBox(width: 21.h),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(block.title, style: CustomTextStyles.promoTitle),
                  SizedBox(height: 2.v),
                  Text(block.body, style: CustomTextStyles.promoBody),
                ],
              ),
            ),
            SizedBox(width: 16.h),
            CustomImageView(
              imagePath: ImageConstant.icArrowRight,
              height: 24.h,
              width: 24.h,
              color: appTheme.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
