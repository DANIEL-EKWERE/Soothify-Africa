import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
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
              Obx(() => Column(
                    children: [
                      for (final entry in controller.shelves.entries) ...[
                        _Shelf(title: entry.key, items: entry.value),
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
        CustomImageView(
          imagePath: ImageConstant.icFilter,
          height: 16.h,
          width: 20.h,
          color: appTheme.actionFill,
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
        CustomImageView(
          imagePath: ImageConstant.icFilter,
          height: 19.h,
          width: 25.h,
          color: appTheme.actionFill,
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
