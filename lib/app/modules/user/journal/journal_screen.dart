import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';
import '../../../data/models/journal_entry.dart';
import '../../../widgets/skeleton.dart';
import 'controller/journal_controller.dart';
import 'widgets/expert_recommendation_view.dart';

/// The Personal Journal — Figma `259:36946` (empty) and `259:36965`
/// (populated).
///
/// A two-way tab over the list, entry cards beneath it, and a compose button
/// floating bottom-right. Measured below the status bar: the tab 112 (40
/// tall, radius 20, full 342 width), the first card 176, cards 137 tall at a
/// 145 pitch, and the button 58 across with its centre at (343, 672).
class JournalScreen extends GetView<JournalController> {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            ImageConstant.icChevronLeft,
            height: 24.h,
            width: 24.h,
            colorFilter: ColorFilter.mode(
              appTheme.textPrimary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: Get.back,
        ),
        title: const Text('Journal'),
      ),
      // Only the journal's own tab can be written to; the other holds what an
      // expert left, so the button would have nothing to do there.
      floatingActionButton: Obx(
        () => controller.tab.value == JournalTab.own
            ? _ComposeButton(onTap: controller.compose)
            : const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 24.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              child: const _TabBar(),
            ),
            Expanded(
              child: Obx(
                () => switch (controller.tab.value) {
                  JournalTab.own => const _OwnEntries(),
                  JournalTab.expert => ExpertRecommendationView(
                    recent: controller.recent,
                    earlier: controller.earlier,
                    onOpen: controller.openRecommendation,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Journal | Expert Recommendation" — one pill, the chosen half painted on
/// the navy title gradient.
class _TabBar extends StatelessWidget {
  const _TabBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JournalController>();
    return Obx(
      () => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 40.v,
            decoration: BoxDecoration(
              color: appTheme.surface,
              borderRadius: BorderRadius.circular(20.h),
              border: Border.all(color: appTheme.segmentTrackBorder),
            ),
            child: Row(
              children: [
                for (final tab in JournalTab.values)
                  Expanded(
                    flex: tab.widthWhen(selected: controller.tab.value == tab),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.select(tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: controller.tab.value == tab
                              ? appTheme.titleGradient
                              : null,
                          borderRadius: BorderRadius.circular(20.h),
                        ),
                        child: Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: controller.tab.value == tab
                              ? CustomTextStyles.journalTabSelected
                              : CustomTextStyles.journalTab,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // The frame hangs the unread count off the control's right end,
          // overlapping it — hence the Stack rather than a trailing child.
          if (controller.unread > 0)
            Positioned(
              right: -5.h,
              top: 11.v,
              child: Container(
                width: 18.h,
                height: 18.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.unreadDot,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${controller.unread}',
                  style: CustomTextStyles.expertTabCount,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OwnEntries extends StatelessWidget {
  const _OwnEntries();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JournalController>();
    return Obx(() {
      if (controller.entries.isEmpty && controller.isLoading.value) {
        return SkeletonShimmer(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(24.h, 24.v, 24.h, 32.v),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (_, _) => SizedBox(height: 8.v),
            itemBuilder: (_, _) => const Skeleton(width: 342, height: 137),
          ),
        );
      }
      if (controller.isEmpty) return const _EmptyState();
      return RefreshIndicator(
        onRefresh: controller.load,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(24.h, 24.v, 24.h, 32.v),
          itemCount: controller.entries.length,
          separatorBuilder: (_, _) => SizedBox(height: 8.v),
          itemBuilder: (context, i) => ContentReveal(
            delay: Duration(milliseconds: 50 * i),
            child: _EntryCard(entry: controller.entries[i]),
          ),
        ),
      );
    });
  }
}

/// A date line, the note's opening line as a heading, then the note itself.
class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JournalController>();
    return InkWell(
      onTap: () => controller.open(entry),
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 137.v,
        // Lands the three bands where the frame puts them inside 137: the
        // date at 20 from the card top, the heading at 45, the note at 75.5.
        padding: EdgeInsets.fromLTRB(17.h, 18.v, 24.h, 10.v),
        decoration: AppDecoration.card,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM d, yyyy').format(entry.createdAt),
                    style: CustomTextStyles.journalEntryDate,
                  ),
                  SizedBox(height: 8.v),
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.journalEntryTitle,
                  ),
                  SizedBox(height: 8.v),
                  Text(
                    entry.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles.journalEntryBody,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.h),
            // The frame draws a chevron, not an arrow; the app ships only a
            // left one, so it is mirrored rather than exported twice.
            Transform.flip(
              flipX: true,
              child: CustomImageView(
                imagePath: ImageConstant.icChevronLeft,
                height: 20.h,
                width: 20.h,
                color: appTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 104.v),
          Center(
            child: CustomImageView(
              imagePath: ImageConstant.imgJournalEmpty,
              height: 73.h,
              width: 73.h,
            ),
          ),
          SizedBox(height: 40.v),
          Text(
            'No entries yet',
            textAlign: TextAlign.center,
            style: CustomTextStyles.emptyStateTitle,
          ),
          SizedBox(height: 8.v),
          Text(
            'There are no limits on topics in your Notepad. Write down how '
            'feel, what you’re planning, or simply something you noticed.',
            textAlign: TextAlign.center,
            style: CustomTextStyles.emptyStateBody,
          ),
        ],
      ),
    );
  }
}

/// The blue disc bottom-right. The earlier build drew the cyan compose glyph
/// the old frames used; both current frames draw a plain white plus on
/// [PrimaryColors.soothifyBlue].
class _ComposeButton extends StatelessWidget {
  const _ComposeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58.h,
        height: 58.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appTheme.soothifyBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: appTheme.textBlack.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add, size: 28.h, color: appTheme.onPrimary),
      ),
    );
  }
}
