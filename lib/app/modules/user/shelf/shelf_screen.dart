import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/media_item.dart';
import '../../../widgets/skeleton.dart';
import 'controller/shelf_controller.dart';

/// A shelf's full page — Figma "Balance Content" (135:20135).
///
/// Two columns of 163x174 cells: cover, then title and practitioner beneath.
/// One route serves every "See All" — the frames differ only in their title
/// and contents.
class ShelfScreen extends GetView<ShelfController> {
  const ShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 0),
              child: Row(
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
                      controller.shelf,
                      textAlign: TextAlign.center,
                      style: CustomTextStyles.appBarTitle,
                    ),
                  ),
                  SizedBox(width: 18.h),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: Obx(() {
                  final loading = controller.isLoading.value &&
                      controller.items.isEmpty;
                  final grid = GridView.builder(
                    padding: EdgeInsets.fromLTRB(24.h, 36.v, 24.h, 32.v),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.h,
                      mainAxisSpacing: 24.v,
                      // 163 wide by 174 tall, as measured.
                      childAspectRatio: 163 / 174,
                    ),
                    itemCount: loading ? 6 : controller.items.length,
                    itemBuilder: (context, i) => loading
                        ? const Skeleton(width: 163, height: 174)
                        : ContentReveal(
                            delay: Duration(milliseconds: 50 * i),
                            child: _GridCard(item: controller.items[i]),
                          ),
                  );
                  return loading ? SkeletonShimmer(child: grid) : grid;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.item});

  final MediaItem item;

  String get _duration {
    final d = item.duration;
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShelfController>();
    return InkWell(
      onTap: () => controller.open(item),
      borderRadius: BorderRadius.circular(8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  // Grows into the detail screen's cover. Safe to key on the
                  // id alone here: a grid lists each item once, so two Heroes
                  // can never share a tag on this screen.
                  child: Hero(
                    tag: 'cover-${item.id}',
                    child: CustomImageView(
                      imagePath: item.coverAsset,
                      fit: BoxFit.cover,
                      radius: BorderRadius.circular(8.h),
                    ),
                  ),
                ),
                Positioned(
                  left: 8.h,
                  top: 8.v,
                  right: 8.h,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    // No `alignment` on the pill's own box — that makes it
                    // expand to the card width instead of hugging its label.
                    child: Container(
                      height: 14.v,
                      padding: EdgeInsets.symmetric(horizontal: 10.h),
                      decoration: BoxDecoration(
                        color: appTheme.onPrimary,
                        borderRadius: BorderRadius.circular(10.h),
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          item.tag,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CustomTextStyles.pillLabel,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8.h,
                  right: 8.h,
                  bottom: 8.v,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MetaPill(
                        asset: ImageConstant.icPlay,
                        label: _duration,
                      ),
                      if (item.rating > 0)
                        _MetaPill(
                          asset: ImageConstant.icStar,
                          label: item.rating.toStringAsFixed(1),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.v),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyles.gridTitle,
          ),
          SizedBox(height: 5.v),
          Text(
            item.practitionerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CustomTextStyles.gridAuthor,
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.h, vertical: 1.v),
      decoration: BoxDecoration(
        color: appTheme.pillDark,
        borderRadius: BorderRadius.circular(10.h),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImageView(
            imagePath: asset,
            height: 6.h,
            width: 6.h,
            color: appTheme.onPrimary,
          ),
          SizedBox(width: 2.h),
          Text(label, style: CustomTextStyles.cardMeta),
        ],
      ),
    );
  }
}
