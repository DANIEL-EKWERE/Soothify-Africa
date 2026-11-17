import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../data/models/passport_reservation.dart';
import '../../../../data/repositories/billing_repository.dart';
import '../../../../data/repositories/spaces_repository.dart';
import '../../../../widgets/custom_elevated_button.dart';
import '../../../../widgets/soothify_word.dart';

/// "Reserve your mat at …?" — the sheet between a class and a held place.
///
/// It says what the reservation costs in classes and what will be left,
/// because this is the only moment the member is told: the allowance is
/// spent here and the balance only reappears on the Hub.
class ReserveSheet extends StatefulWidget {
  const ReserveSheet({
    super.key,
    required this.sessionId,
    required this.studioName,
  });

  final int sessionId;
  final String studioName;

  /// Opens the sheet and answers with the place that was taken, or null if
  /// the member backed out or it could not be taken.
  static Future<PassportReservation?> show(
    BuildContext context, {
    required int sessionId,
    required String studioName,
  }) {
    return showModalBottomSheet<PassportReservation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: appTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.h)),
      ),
      builder: (_) => ReserveSheet(
        sessionId: sessionId,
        studioName: studioName,
      ),
    );
  }

  @override
  State<ReserveSheet> createState() => _ReserveSheetState();
}

class _ReserveSheetState extends State<ReserveSheet> {
  int? _remaining;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _readBalance();
  }

  Future<void> _readBalance() async {
    try {
      final membership = await Get.find<BillingRepository>().membership();
      if (mounted) {
        setState(() => _remaining = membership.passportRemaining);
      }
    } on AppException {
      // The figure is the nicety; reserving is the point. The sheet reads
      // without it rather than refusing to open.
      if (mounted) setState(() => _remaining = null);
    }
  }

  Future<void> _confirm() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final held =
          await Get.find<SpacesRepository>().reserve(widget.sessionId);
      Get.back<PassportReservation>(result: held);
    } on AppException catch (failure) {
      if (mounted) setState(() => _working = false);
      // A full class or a spent allowance is a refusal with a reason, and
      // the server's wording is better than anything guessed here.
      AppFeedback.error(failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final after = _remaining == null ? null : _remaining! - 1;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.h, 12.v, 24.h, 24.v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4.v,
              width: 48.h,
              decoration: BoxDecoration(
                color: appTheme.cardRim,
                borderRadius: BorderRadius.circular(4.h),
              ),
            ),
            SizedBox(height: 28.v),
            Container(
              height: 80.h,
              width: 80.h,
              decoration: BoxDecoration(
                color: appTheme.soothifyBlue.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.spa_outlined,
                  size: 40.h, color: appTheme.soothifyBlue),
            ),
            SizedBox(height: 24.v),
            Text(
              'passport.reserveAt'.trParams({'studio': widget.studioName}),
              textAlign: TextAlign.center,
              style: CustomTextStyles.tierName,
            ),
            SizedBox(height: 12.v),
            SoothifyText(
              after == null
                  ? 'passport.reserveBodyPlain'.tr
                  : 'passport.reserveBody'.trParams({'left': '$after'}),
              textAlign: TextAlign.center,
              style: CustomTextStyles.passportFor,
            ),
            SizedBox(height: 24.v),
            if (after != null)
              Container(
                width: double.infinity,
                padding:
                    EdgeInsets.symmetric(horizontal: 16.h, vertical: 14.v),
                decoration: BoxDecoration(
                  color: appTheme.soothifyBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.h),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('passport.balanceAfter'.tr,
                          style: CustomTextStyles.passportFor),
                    ),
                    Text(
                      '$after ${'passport.classesWord'.tr}',
                      style: CustomTextStyles.statsHeading,
                    ),
                  ],
                ),
              ),
            SizedBox(height: 24.v),
            CustomElevatedButton(
              text: _working
                  ? 'passport.reserving'.tr
                  : 'passport.confirmReservation'.tr,
              onPressed: _working ? null : _confirm,
            ),
          ],
        ),
      ),
    );
  }
}
