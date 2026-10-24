import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../shell/tabs/widgets/recommended_card.dart';
import 'controller/favourites_controller.dart';

/// Everything hearted, newest first — reached from Settings.
///
/// The same card Home draws, so a piece looks the same wherever it is met.
/// Its heart is filled here by definition, and tapping it takes the row
/// off the list.
class FavouritesScreen extends GetView<FavouritesController> {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 22.v, 24.h, 16.v),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(Icons.arrow_back_ios_new,
                        size: 16.h, color: appTheme.textPrimary),
                  ),
                  SizedBox(width: 12.h),
                  Text('Favourites', style: CustomTextStyles.joiningHeading),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.items.isEmpty) return const _Empty();

                return RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                    itemCount: controller.items.length,
                    separatorBuilder: (_, _) => SizedBox(height: 8.h),
                    itemBuilder: (_, i) {
                      final item = controller.items[i];
                      return RecommendedCard(
                        item: item,
                        onTap: () => controller.open(item),
                        onHeart: () => controller.remove(item),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 48.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImageView(
              imagePath: ImageConstant.icHeart,
              height: 32.h,
              width: 32.h,
              color: appTheme.navInactive,
            ),
            SizedBox(height: 16.v),
            Text(
              'Nothing saved yet',
              textAlign: TextAlign.center,
              style: CustomTextStyles.coachSection,
            ),
            SizedBox(height: 8.v),
            Text(
              // Says where the heart is rather than only that the list is
              // empty: an empty screen that does not say how to fill it is
              // a dead end.
              'Tap the heart on anything in the library and it will be here.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.coachBlurb,
            ),
          ],
        ),
      ),
    );
  }
}
