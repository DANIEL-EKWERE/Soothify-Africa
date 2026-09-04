import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../widgets/gradient_text.dart';
import 'controller/compose_controller.dart';

/// Start a discussion — Figma 135:5783.
///
/// One body field and a Post button; the design captures no title, so the
/// first line of the body becomes the thread heading.
class ComposeScreen extends GetView<ComposeController> {
  const ComposeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.h, 17.v, 24.h, 24.v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: Get.back,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 14.h,
                    color: appTheme.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 49.v),
              Text(
                'Share your thoughts or ask questions',
                textAlign: TextAlign.center,
                style: CustomTextStyles.appBarTitle,
              ),
              SizedBox(height: 55.v),
              Container(
                height: 161.v,
                padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 8.v),
                decoration: BoxDecoration(
                  color: appTheme.fieldFill,
                  borderRadius: BorderRadius.circular(8.h),
                  border: Border.all(color: appTheme.navInactive),
                ),
                child: TextField(
                  controller: controller.body,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: CustomTextStyles.topicChip,
                  decoration: InputDecoration(
                    hintText: 'Write......',
                    hintStyle: CustomTextStyles.pillLabel
                        .copyWith(color: appTheme.navInactive),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.h),
                  ),
                ),
              ),
              SizedBox(height: 24.v),
              Align(
                alignment: Alignment.centerRight,
                child: Obx(() => InkWell(
                      onTap: controller.canPost.value ? controller.post : null,
                      borderRadius: BorderRadius.circular(8.h),
                      child: Container(
                        width: 89.h,
                        height: 42.v,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: appTheme.surface,
                          borderRadius: BorderRadius.circular(8.h),
                        ),
                        // Gradient-filled in the design; dimmed rather than
                        // hidden when there is nothing to post.
                        child: Opacity(
                          opacity: controller.canPost.value ? 1 : 0.4,
                          child: GradientText(
                            'Post',
                            gradient: appTheme.navActiveGradient,
                            style: CustomTextStyles.appBarTitle,
                          ),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
