import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/explore_destination.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/services/session_service.dart';
import '../../../../data/services/theme_service.dart';
import '../../../../widgets/gradient_text.dart';
import 'home_tab_controller.dart';
import 'widgets/ai_assist_button.dart';
import 'widgets/content_pills.dart';
import 'widgets/recommended_card.dart';

/// Home — Figma "Home screen/Unsigned" (1051:8496).
///
/// Built from a plugin JSON export; measured values are recorded in
/// tool/figma_export/home_spec.md. The export resolved auto-layout rather than
/// absolute positions, so this is expressed as real Columns and Rows with the
/// design's own gaps and padding.
///
/// Two things the export could not supply, both marked at their use sites:
/// artwork (no image refs came through) and anything that was a component
/// instance — the icons, and the Mood Checker card's own background fill.
class HomeTab extends GetView<HomeTabController> {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.reload,
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 8.h, 24.h, 32.h),
                children: [
                  const _Header(),
                  SizedBox(height: 24.h),
                  const _MoodCheckerCard(),
                  SizedBox(height: 40.h),
                  const _ExploreSection(),
                  SizedBox(height: 40.h),
                  const _RecommendedSection(),
                  SizedBox(height: 40.h),
                  const _PopularSection(),
                ],
              ),
            ),
            // LayoutBuilder so the button knows the area it may be dragged
            // within; without it a drag could put it off-screen.
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  children: [
                    AiAssistButton(
                      onTap: controller.openAiAssist,
                      bounds: constraints.biggest,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    // Two frames: signed in (135:518) leads with the avatar and greets by
    // name; unsigned (135:705) has neither and greets by time of day. The
    // right-hand cluster is the same in both.
    final guest = Get.find<SessionService>().isGuest;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!guest) ...[
          ClipOval(
            child: CustomImageView(
              imagePath: ImageConstant.imgHomeAvatar,
              height: 44.h,
              width: 44.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 7.h),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (guest)
                // The frame shows "Good morning"; a fixed one would be wrong
                // for most of the day, so it follows the clock.
                Text(
                  Get.find<HomeTabController>().greeting,
                  style: CustomTextStyles.homeGreeting.copyWith(
                    color: appTheme.soothifyBlue,
                  ),
                )
              else
                GradientText(
                  'Hi, Dera',
                  gradient: appTheme.titleGradient,
                  style: CustomTextStyles.homeGreeting,
                ),
              SizedBox(height: 1.h),
              Text(
                'How are you today?',
                style: CustomTextStyles.homeGreetingSub,
              ),
            ],
          ),
        ),
        // The header's right cluster is the dark-mode toggle then the bell,
        // 8 apart — the toggle was missing, and dark mode was only reachable
        // by long-pressing the bell, which nothing advertised.
        GestureDetector(
          onTap: () => Get.find<ThemeService>().toggle(context),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.h, vertical: 10.v),
            child: CustomImageView(
              imagePath: ImageConstant.icDarkMode,
              height: 24.h,
              width: 24.h,
              color: appTheme.brandDeep,
            ),
          ),
        ),
        SizedBox(width: 8.h),
        GestureDetector(
          child: Container(
            width: 44.h,
            height: 44.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: appTheme.bellBorder, width: 0.5),
            ),
            child: CustomImageView(
              imagePath: ImageConstant.icBell,
              height: 20.h,
              width: 20.h,
              color: appTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MoodCheckerCard extends StatelessWidget {
  const _MoodCheckerCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.moodChecker),
      child: Container(
        height: 88.h,
        padding: EdgeInsets.symmetric(horizontal: 23.h),
        decoration: BoxDecoration(
          gradient: appTheme.moodCardGradient,
          borderRadius: BorderRadius.circular(8.h),
        ),
        child: Row(
          children: [
            // Straight image, not ArtworkPlaceholder: that paints a backing
            // block so a missing cover cannot blank a card, which is right
            // for artwork that fills its box but shows through a transparent
            // icon as a pale square behind it.
            CustomImageView(
              imagePath: ImageConstant.imgMoodCheckerIcon,
              height: 38.h,
              width: 38.h,
            ),
            SizedBox(width: 15.h),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mood Checker', style: CustomTextStyles.homeCardTitle),
                  SizedBox(height: 2.h),
                  Text(
                    'Take a moment to check in with yourself. Be gentle and '
                    'kind, acknowledging how you truly feel.',
                    style: CustomTextStyles.homeCardBody,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            SizedBox(width: 24.h),
            CustomImageView(
              imagePath: ImageConstant.icArrowRight,
              height: 20.h,
              width: 20.h,
              color: appTheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreSection extends StatelessWidget {
  const _ExploreSection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeTabController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explore', style: CustomTextStyles.sectionTitle),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final destination in controller.explore)
              _ExploreTile(
                destination: destination,
                onTap: () => controller.openExplore(destination),
              ),
          ],
        ),
      ],
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({required this.destination, this.onTap});

  final ExploreDestination destination;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 100.h,
        child: Column(
          children: [
            Container(
              height: 90.h,
              width: 100.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.surface,
                border: Border.all(color: appTheme.exploreTileBorder),
                borderRadius: BorderRadius.circular(8.h),
              ),
              child: ArtworkPlaceholder(
                width: destination.artSize.h,
                height: destination.artSize.h,
                radius: 8.h,
                assetPath: destination.assetPath,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              destination.label,
              textAlign: TextAlign.center,
              style: CustomTextStyles.exploreLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeTabController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommended for you', style: CustomTextStyles.sectionTitle),
        SizedBox(height: 16.h),
        Obx(
          () => Column(
            children: [
              for (final item in controller.recommended) ...[
                RecommendedCard(
                  item: item,
                  // A card opens the item; the section heading's "See All"
                  // is what opens the full list.
                  onTap: () =>
                      controller.open(item, source: 'Recommended for you'),
                ),
                if (item != controller.recommended.last) SizedBox(height: 8.h),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PopularSection extends StatelessWidget {
  const _PopularSection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeTabController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Popular Content', style: CustomTextStyles.popularHeading),
            GestureDetector(
              onTap: controller.seeAllPopular,
              child: Text('See All', style: CustomTextStyles.seeAll),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 166.h,
          child: Obx(
            () => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.popular.length,
              separatorBuilder: (_, _) => SizedBox(width: 20.h),
              itemBuilder: (_, i) => _PopularCard(item: controller.popular[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _PopularCard extends StatelessWidget {
  const _PopularCard({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.find<HomeTabController>().open(item, source: 'Popular Content'),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 159.h,
        height: 166.h,
        child: Stack(
          children: [
            ArtworkPlaceholder(
              width: 159.h,
              height: 166.h,
              radius: 8.h,
              assetPath: item.coverAsset,
            ),
            Positioned(
              top: 8.h,
              left: 8.h,
              child: CategoryPill(label: item.title),
            ),
            Positioned(
              left: 8.h,
              right: 8.h,
              bottom: 8.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DarkPill(
                    asset: ImageConstant.icPlay,
                    label:
                        '${item.duration.inMinutes.toString().padLeft(2, '0')}'
                        ':00',
                  ),
                  DarkPill(asset: ImageConstant.icStar, label: '4.6'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
