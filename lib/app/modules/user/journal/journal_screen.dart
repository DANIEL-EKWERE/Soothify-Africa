import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_export.dart';
import '../shell/tabs/widgets/content_pills.dart';
import 'controller/journal_controller.dart';

/// Journal — Figma `135:2091`, the empty state.
///
/// Positions from the frame: artwork 73 square at 239, heading at 352, body at
/// 387 across 342, and a 48px compose button at (318, 648).
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
            colorFilter:
                ColorFilter.mode(appTheme.textPrimary, BlendMode.srcIn),
          ),
          onPressed: Get.back,
        ),
        title: const Text('Journal'),
      ),
      floatingActionButton: GestureDetector(
        onTap: controller.compose,
        child: Container(
          width: 48.h,
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: appTheme.journalAccent,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.edit_outlined,
              size: 22.h, color: appTheme.onPrimary),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => controller.isEmpty
              ? const _EmptyState()
              // The populated design (135:2105) has not been read yet; until
              // then a plain list keeps the screen honest rather than
              // inventing a row treatment.
              : ListView.separated(
                  padding: EdgeInsets.all(24.h),
                  itemCount: controller.entries.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, i) {
                    final entry = controller.entries[i];
                    return Container(
                      padding: EdgeInsets.all(16.h),
                      decoration: AppDecoration.card,
                      child: Text(entry.body,
                          style: CustomTextStyles.emptyStateBody),
                    );
                  },
                ),
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
          SizedBox(height: 128.h),
          Center(child: ArtworkPlaceholder(width: 73.h, height: 73.h)),
          SizedBox(height: 40.h),
          Text('No entries yet',
              textAlign: TextAlign.center,
              style: CustomTextStyles.emptyStateTitle),
          SizedBox(height: 8.h),
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
