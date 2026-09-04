import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';
import 'controller/journal_compose_controller.dart';

/// Writing a journal entry — Figma `135:2105`.
///
/// A date/time bar with a Done action, a prompt in a pale card, a way to swap
/// the prompt, the entry itself, and a message field pinned to the bottom.
///
/// The frame's copy is outlined to vectors rather than live text, so the
/// strings here were read from a render of it; positions and colours come from
/// the node data as usual.
class JournalComposeScreen extends GetView<JournalComposeController> {
  const JournalComposeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const _HeaderBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 18.h),
                    const _PromptCard(),
                    SizedBox(height: 16.h),
                    const _ChangePrompt(),
                    SizedBox(height: 24.h),
                    TextField(
                      controller: controller.bodyController,
                      maxLines: null,
                      style: CustomTextStyles.journalPrompt,
                      cursorColor: appTheme.soothifyBlue,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'I had an amazing...',
                        hintStyle: CustomTextStyles.journalPrompt,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _MessageField(),
          ],
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JournalComposeController>();
    final at = controller.startedAt;

    return Container(
      height: 35.h,
      padding: EdgeInsets.symmetric(horizontal: 15.h),
      decoration: BoxDecoration(
        border: Border.all(color: appTheme.optionBorder),
      ),
      child: Row(
        children: [
          Text(DateFormat('EEE, d MMM yyyy').format(at),
              style: CustomTextStyles.journalDate),
          SizedBox(width: 11.h),
          Text(DateFormat('H:mm').format(at),
              style: CustomTextStyles.journalPrompt),
          const Spacer(),
          GestureDetector(
            onTap: controller.done,
            child: Text('Done', style: CustomTextStyles.journalDate),
          ),
          SizedBox(width: 60.h),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JournalComposeController>();
    return Container(
      constraints: BoxConstraints(minHeight: 64.h),
      padding: EdgeInsets.symmetric(horizontal: 33.h, vertical: 14.h),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: appTheme.promptCard,
        borderRadius: BorderRadius.circular(8.h),
      ),
      child: Obx(
        () => Text(controller.prompt, style: CustomTextStyles.journalPrompt),
      ),
    );
  }
}

class _ChangePrompt extends StatelessWidget {
  const _ChangePrompt();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JournalComposeController>();
    return GestureDetector(
      onTap: controller.changePrompt,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.refresh, size: 10.h, color: appTheme.textPrimary),
          SizedBox(width: 8.h),
          Text('Change prompt', style: CustomTextStyles.journalChangePrompt),
        ],
      ),
    );
  }
}

/// The pill at the foot of the screen. Sits above the keyboard rather than
/// under it, which the static frame cannot show but the screen needs.
class _MessageField extends StatelessWidget {
  const _MessageField();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JournalComposeController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(24.h, 8.h, 24.h, 16.h),
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 11.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(20.h),
          border: Border.all(color: appTheme.navInactive),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.messageController,
                style: CustomTextStyles.journalChangePrompt
                    .copyWith(fontSize: 12.fSize),
                cursorColor: appTheme.soothifyBlue,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Type in your message',
                  hintStyle: CustomTextStyles.journalChangePrompt.copyWith(
                    fontSize: 12.fSize,
                    color: appTheme.navInactive,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.send,
              child: Icon(Icons.send_outlined,
                  size: 20.h, color: appTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
