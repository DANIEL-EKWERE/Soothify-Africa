import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/practice_protection.dart';
import '../../../widgets/soothify_word.dart';
import '../widgets/expert_header.dart';

/// Care & protection hub — what Soothify guarantees a practitioner.
///
/// A heading, a line, then one card per assurance: a tinted disc holding its
/// glyph, the name, and two lines saying what it actually covers.
///
/// The frame's own blurb here is the availability screen's — "Clients can
/// only book during the times you set below." — pasted onto a protection
/// screen. This one says what the screen is for, as the joining screen's did.
class CareProtectionScreen extends StatelessWidget {
  const CareProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            const ExpertHeader(title: 'Care & protection hub'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 25.v, 24.h, 32.v),
                children: [
                  Text('Your practice, fully protected',
                      style: CustomTextStyles.expertSection),
                  SizedBox(height: 8.v),
                  SoothifyText(
                    'What Soothify covers for you, on every session you take.',
                    style: CustomTextStyles.expertBlurb,
                  ),
                  SizedBox(height: 24.v),
                  for (final item in PracticeProtection.values) ...[
                    _ProtectionCard(item: item),
                    SizedBox(height: 16.v),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProtectionCard extends StatelessWidget {
  const _ProtectionCard({required this.item});

  final PracticeProtection item;

  /// Each card's disc takes its own tint, as the frame draws them — blue,
  /// green and amber, in the order they appear.
  Color get _tint => switch (item) {
        PracticeProtection.noShow => appTheme.soothifyBlue,
        PracticeProtection.secureNotes => appTheme.statusLiveInk,
        PracticeProtection.spotlight => appTheme.accent,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        // 4% black: a card on white takes a hairline, not an outline.
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.h,
            height: 40.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.h),
            ),
            child: CustomImageView(
              imagePath: item.asset,
              height: 20.h,
              width: 20.h,
              color: _tint,
            ),
          ),
          SizedBox(width: 14.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: CustomTextStyles.expertOutcomeTitle),
                SizedBox(height: 8.v),
                Text(item.body, style: CustomTextStyles.expertBlurb),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
