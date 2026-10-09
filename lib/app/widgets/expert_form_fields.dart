import 'package:flutter/material.dart';

import '../core/app_export.dart';
import '../data/models/expert_application.dart';

/// A choosable row on the application form — Figma `259:59145`, `259:59179`.
///
/// Shared: the expert application and the expert's own session notes
/// (`259:59854`) draw the same field and the same option row.
///
/// 342x48, radius 8, white inside a 1px `#263238` hairline, label inset 13.
/// The frames draw no radio or checkbox and no chosen state at all; picking
/// one fills it the way the rest of the app's questionnaires do, so the
/// answer is visible.
class ExpertOptionRow extends StatelessWidget {
  const ExpertOptionRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48.v,
        padding: EdgeInsets.symmetric(horizontal: 13.h),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          // Outlined when chosen, never filled: the solid blue belongs to
          // Next at the foot of the form. At rest the hairline is the app's
          // 4% black — it was drawing in near black, which made every
          // unchosen option look as emphatic as a chosen one.
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(
            color: selected ? appTheme.soothifyBlue : appTheme.cardRim,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(label, style: CustomTextStyles.optionLabel),
      ),
    );
  }
}

/// A question with its input beneath — the frames keep 8 between them.
///
/// 342x48 (163 for the "tell us about yourself" box), radius 8, `#F9F9F9`
/// inside a hairline. Not [FilledTextField]: that one is the auth screens',
/// with a 4 radius and a lighter label.
class ExpertFormField extends StatelessWidget {
  const ExpertFormField({
    super.key,
    required this.label,
    required this.controller,
    this.height = 48,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final double height;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: CustomTextStyles.expertFormLabel),
        SizedBox(height: 8.v),
        Container(
          height: height.v,
          padding: EdgeInsets.symmetric(horizontal: 13.h, vertical: 12.v),
          decoration: BoxDecoration(
            color: appTheme.fieldFill,
            borderRadius: BorderRadius.circular(8.h),
            border: Border.all(color: appTheme.rowBorder, width: 0.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            maxLines: maxLines,
            expands: maxLines == null,
            textAlignVertical: TextAlignVertical.top,
            style: CustomTextStyles.optionLabel,
            cursorColor: appTheme.soothifyBlue,
            decoration: const InputDecoration(
              isDense: true,
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// "Add file" — Figma `259:59198`.
///
/// An 82x34 chip, radius 8, `#F9F9F9` inside a 1px hairline, with a small
/// upload glyph at its left and the label in blue. The hairline is blue too:
/// it was drawing in near black, so the chip read as disabled beside its own
/// blue label.
///
/// The frame draws only the empty state. Once a document is picked the chip
/// gives way to a row naming it, with its size and a way to drop it — a slot
/// that still reads "Add file" after a successful pick would be telling the
/// applicant their certificate did not take.
class ExpertUploadChip extends StatelessWidget {
  const ExpertUploadChip({
    super.key,
    required this.onTap,
    this.attached,
    this.onRemove,
  });

  final VoidCallback onTap;

  /// What is in this slot, if anything.
  final AttachedDocument? attached;

  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final file = attached;
    if (file == null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 82.h,
          height: 34.v,
          padding: EdgeInsets.symmetric(horizontal: 11.h),
          decoration: BoxDecoration(
            color: appTheme.fieldFill,
            borderRadius: BorderRadius.circular(8.h),
            border: Border.all(color: appTheme.soothifyBlue),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.file_upload_outlined,
                size: 13.h,
                color: appTheme.soothifyBlue,
              ),
              SizedBox(width: 3.h),
              Text('Add file', style: CustomTextStyles.expertAddFile),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 48.v,
      padding: EdgeInsets.symmetric(horizontal: 11.h),
      decoration: BoxDecoration(
        color: appTheme.fieldFill,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.soothifyBlue),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description_outlined,
            size: 18.h,
            color: appTheme.soothifyBlue,
          ),
          SizedBox(width: 8.h),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.expertAddFile
                      .copyWith(color: appTheme.textPrimary),
                ),
                Text(file.size, style: CustomTextStyles.expertAddFile),
              ],
            ),
          ),
          SizedBox(width: 8.h),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Icon(Icons.close, size: 18.h, color: appTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
