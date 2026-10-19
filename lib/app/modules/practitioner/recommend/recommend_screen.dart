import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/media_item.dart';
import '../../../widgets/custom_elevated_button.dart';
import 'controller/recommend_controller.dart';

/// Picking a piece of the library to send a client mid-call.
///
/// Reached from the call screen's "..." → "Recommend Contents" → a kind.
/// The kind is already chosen, so this lists only that kind: searching
/// across all three would undo the choice the practitioner just made.
class RecommendScreen extends GetView<RecommendController> {
  const RecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.items.isEmpty) {
                  return _Empty(controller: controller);
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(24.h, 8.v, 24.h, 24.v),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.v),
                  itemBuilder: (_, i) {
                    final item = controller.items[i];
                    return Obx(() => _Row(
                          item: item,
                          chosen: controller.chosen.value?.id == item.id,
                          onTap: () => controller.choose(item),
                        ));
                  },
                );
              }),
            ),
            _Footer(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final RecommendController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.h, 22.v, 24.h, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: Get.back,
                behavior: HitTestBehavior.opaque,
                child: Icon(Icons.arrow_back_ios_new,
                    size: 16.h, color: appTheme.textPrimary),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: Text(controller.title,
                    style: CustomTextStyles.joiningHeading),
              ),
            ],
          ),
          SizedBox(height: 4.v),
          Text('Goes to ${controller.clientName}',
              style: CustomTextStyles.expertBlurb),
          SizedBox(height: 16.v),
          TextField(
            onChanged: (value) => controller.query.value = value,
            style: CustomTextStyles.expertRowLabel,
            decoration: InputDecoration(
              hintText: 'Search the library',
              hintStyle: CustomTextStyles.expertBlurb,
              prefixIcon:
                  Icon(Icons.search, size: 20.h, color: appTheme.navInactive),
              filled: true,
              fillColor: appTheme.surface,
              contentPadding: EdgeInsets.symmetric(vertical: 12.v),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.h),
                borderSide: BorderSide(color: appTheme.cardRim),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.h),
                borderSide: BorderSide(color: appTheme.cardRim),
              ),
            ),
          ),
          SizedBox(height: 12.v),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.chosen, required this.onTap});

  final MediaItem item;
  final bool chosen;
  final VoidCallback onTap;

  String get _meta {
    final minutes = (item.durationSeconds / 60).round();
    return [
      if (minutes > 0) '$minutes min',
      if (item.tag.isNotEmpty) item.tag,
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(10.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(
            color: chosen ? appTheme.soothifyBlue : appTheme.cardRim,
            width: chosen ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6.h),
              child: CustomImageView(
                imagePath: item.coverUrl.isNotEmpty
                    ? item.coverUrl
                    : item.coverAsset,
                height: 56.h,
                width: 56.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles.expertRowLabel),
                  if (_meta.isNotEmpty) ...[
                    SizedBox(height: 4.v),
                    Text(_meta, style: CustomTextStyles.expertBlurb),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.h),
            Icon(
              chosen ? Icons.check_circle : Icons.circle_outlined,
              size: 22.h,
              color: chosen ? appTheme.soothifyBlue : appTheme.navInactive,
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.controller});

  final RecommendController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.h),
        child: Text(
          controller.query.value.isEmpty
              // Not "no results": with no search running, an empty list
              // means the library holds nothing of this kind at all, and
              // searching again will not help.
              ? 'There is nothing of this kind in the library yet.'
              : 'Nothing matches that.',
          textAlign: TextAlign.center,
          style: CustomTextStyles.expertBlurb,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.controller});

  final RecommendController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chosen = controller.chosen.value;
      if (chosen == null) return const SizedBox.shrink();
      return Container(
        padding: EdgeInsets.fromLTRB(24.h, 16.v, 24.h, 20.v),
        decoration: BoxDecoration(
          color: appTheme.surface,
          border: Border(top: BorderSide(color: appTheme.cardRim)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!controller.pickOnly) TextField(
              controller: controller.note,
              maxLines: 2,
              minLines: 1,
              style: CustomTextStyles.expertRowLabel,
              decoration: InputDecoration(
                hintText: 'Say why, in a line (optional)',
                hintStyle: CustomTextStyles.expertBlurb,
                filled: true,
                fillColor: appTheme.background,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.v),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.h),
                  borderSide: BorderSide(color: appTheme.cardRim),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.h),
                  borderSide: BorderSide(color: appTheme.cardRim),
                ),
              ),
            ),
            if (!controller.pickOnly) SizedBox(height: 12.v),
            CustomElevatedButton(
              text: controller.sending.value
                  ? 'Sending…'
                  : controller.actionLabel,
              onPressed: controller.canSend ? controller.send : null,
            ),
          ],
        ),
      );
    });
  }
}
