import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/media_item.dart';
import '../../../widgets/content_search_row.dart';
import '../../../widgets/skeleton.dart';
import '../discovery/widgets/discovery_card.dart';
import 'controller/videos_controller.dart';

/// The video library — Figma "Video Contents" (`259:60948`).
///
/// Measured below the status bar: the header 69, the search row 115 (48 tall,
/// the field 289 wide and the filter glyph at 341), the first shelf heading
/// 194.5 and its cards 228 (166 tall, 159 wide, 20 apart), the second heading
/// 430.5. Same card and shelf metrics as a library screen, which is why the
/// Discovery card is reused rather than redrawn.
class VideosScreen extends GetView<VideosController> {
  const VideosScreen({super.key});

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
              const _Header(),
              SizedBox(height: 27.v),
              Obx(
                () => ContentSearchRow(
                  hint: "Let's find your calm",
                  filterCount: controller.filters.value.count,
                  onSearch: controller.openSearch,
                  onFilters: controller.openFilters,
                ),
              ),
              SizedBox(height: 31.5.v),
              Obx(
                () => Column(
                  children: [
                    for (final shelf in VideosController.catalogue) ...[
                      _Shelf(
                        title: shelf.title,
                        items: controller.shelves[shelf.title] ?? const [],
                      ),
                      SizedBox(height: 36.5.v),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
            'Videos',
            textAlign: TextAlign.center,
            style: CustomTextStyles.appBarTitle,
          ),
        ),
        SizedBox(width: 18.h),
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
    final controller = Get.find<VideosController>();
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
        SizedBox(height: 19.5.v),
        SizedBox(
          height: 166.v,
          child: _Rail(title: title, items: items),
        ),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.title, required this.items});

  final String title;
  final List<MediaItem> items;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideosController>();
    if (items.isEmpty && controller.isLoading.value) {
      return SkeletonShimmer(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, _) => SizedBox(width: 20.h),
          itemBuilder: (_, _) => const Skeleton(width: 159, height: 166),
        ),
      );
    }
    // A duration filter can empty a row outright; a heading over 166 of
    // nothing reads as a failed load.
    if (items.isEmpty) {
      return Text(
        controller.filters.value.isEmpty
            ? 'No videos here yet.'
            : 'Nothing here matches your filters.',
        style: CustomTextStyles.emptyStateBody,
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(width: 20.h),
      itemBuilder: (context, i) => DiscoveryCard(
        item: items[i],
        onTap: () => controller.open(items[i], source: title),
      ),
    );
  }
}
