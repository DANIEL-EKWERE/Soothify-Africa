import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/explore_destination.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/services/theme_service.dart';
import '../../../../widgets/gradient_text.dart';
import 'home_tab_controller.dart';
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
            Positioned(
              right: 4.h,
              bottom: 16.h,
              child: const _AiAssistButton(),
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
    // Signed in, the header leads with the user's avatar and greets by name;
    // the greeting itself is gradient-filled. The unsigned variant has neither.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44.h,
          height: 44.h,
          decoration: BoxDecoration(
            color: appTheme.avatarBacking,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.person, size: 24.h, color: appTheme.surface),
        ),
        SizedBox(width: 7.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GradientText(
                'Hi, Dera',
                gradient: appTheme.titleGradient,
                style: CustomTextStyles.homeGreeting,
              ),
              SizedBox(height: 1.h),
              Text('How are you today?',
                  style: CustomTextStyles.homeGreetingSub),
            ],
          ),
        ),
        GestureDetector(
          // The design shows only the bell here; the theme toggle lives in
          // Settings. Kept on a long-press so dark mode stays reachable while
          // that screen is unbuilt.
          onLongPress: () => Get.find<ThemeService>().toggle(context),
          child: Container(
            width: 44.h,
            height: 44.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: appTheme.bellBorder, width: 0.5),
            ),
            child: Icon(Icons.notifications_none,
                size: 20.h, color: appTheme.textPrimary),
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
            ArtworkPlaceholder(width: 38.h, height: 38.h, radius: 4.h),
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
            Icon(Icons.chevron_right, size: 20.h, color: appTheme.onPrimary),
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
                  onTap: () => Get.toNamed(AppRoutes.recommendation),
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
    return SizedBox(
      width: 159.h,
      height: 166.h,
      child: Stack(
        children: [
          ArtworkPlaceholder(width: 159.h, height: 166.h, radius: 8.h),
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
                  icon: Icons.play_arrow,
                  label:
                      '${item.duration.inMinutes.toString().padLeft(2, '0')}'
                      ':00',
                ),
                const DarkPill(icon: Icons.star, label: '4.6'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The floating AI Therapy Assist button — 70x70, soft shadow.
class _AiAssistButton extends StatelessWidget {
  const _AiAssistButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Get.find<HomeTabController>().openAiAssist,
      child: Container(
        width: 70.h,
        height: 70.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.surface,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: const Color(0x52000000), blurRadius: 4)],
        ),
        child: Icon(
          Icons.support_agent,
          size: 32.h,
          color: appTheme.soothifyBlue,
        ),
      ),
    );
  }
}
