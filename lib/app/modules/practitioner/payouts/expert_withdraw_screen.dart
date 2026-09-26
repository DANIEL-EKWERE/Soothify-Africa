import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../data/models/payout_method.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../widgets/expert_header.dart';
import '../widgets/expert_money.dart';
import 'controller/payout_controller.dart';

/// Withdrawing — Figma "Payout amount input" (`259:59559`).
///
/// Measured: the title at 70, the figure at 215 (Nunito 700 32, centred), a
/// 254x39 pill at 275.2 filled `#EDF6FE` with its line in `#2F6FED`,
/// "Destination of funds" at 388, and three 109x86 tiles at 425.
///
/// The frame shows the system keyboard filling its lower half, so the figure
/// is typed; this uses a real field rather than drawing keys.
class ExpertWithdrawScreen extends GetView<PayoutController> {
  const ExpertWithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            const ExpertHeader(title: 'Withdrawal'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 90.v, 24.h, 24.v),
                children: [
                  // Typed, but styled as the frame's big centred figure
                  // rather than as a form field.
                  //
                  // The sign is a sibling, not the field's `prefixText`:
                  // that anchors to the field's left edge while the digits
                  // stay centred, which strands the ₦ across the screen.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('₦', style: CustomTextStyles.withdrawAmount),
                      IntrinsicWidth(
                        child: TextField(
                          controller: controller.amount,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: CustomTextStyles.withdrawAmount,
                          cursorColor: appTheme.soothifyBlue,
                          onChanged: (_) {
                            controller.markEdited();
                            // Re-evaluates canProceed and the balance note.
                            controller.method.refresh();
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                            hintStyle: CustomTextStyles.withdrawAmount
                                .copyWith(color: appTheme.hintText),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.v),
                  Center(
                    child: Container(
                      height: 39.v,
                      padding: EdgeInsets.symmetric(horizontal: 10.h),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: appTheme.policyPanel,
                        borderRadius: BorderRadius.circular(24.h),
                      ),
                      child: Text('How much do you want to withdraw',
                          style: CustomTextStyles.withdrawPrompt),
                    ),
                  ),
                  SizedBox(height: 16.v),
                  Obx(
                    () => Center(
                      child: Text(
                        controller.requested > controller.available
                            ? 'You have ${money(controller.available)} '
                                'available.'
                            : '',
                        style: CustomTextStyles.expertCardMeta
                            .copyWith(color: appTheme.error),
                      ),
                    ),
                  ),
                  SizedBox(height: 41.v),
                  Text('Destination of funds',
                      style: CustomTextStyles.expertSection),
                  SizedBox(height: 16.v),
                  const _DestinationTiles(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
              child: Obx(
                () => CustomElevatedButton(
                  text: 'Proceed',
                  isEnabled: controller.canProceed,
                  onPressed: controller.openMethod,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three 109x86 tiles in a row; the chosen one takes the blue outline.
class _DestinationTiles extends StatelessWidget {
  const _DestinationTiles();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayoutController>();
    return Obx(
      () => Row(
        children: [
          for (final method in PayoutMethod.values) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => controller.choose(method),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 86.v,
                  padding: EdgeInsets.all(9.h),
                  decoration: BoxDecoration(
                    color: appTheme.surface,
                    borderRadius: BorderRadius.circular(8.h),
                    border: Border.all(
                      color: controller.method.value == method
                          ? appTheme.soothifyBlue
                          : appTheme.textPrimary,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24.h,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color:
                              appTheme.textPrimary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Spacer(),
                      // Bank Transfer's tile is headed by the account and
                      // says the method beneath; the other two have no
                      // account, and their labels already take both lines.
                      Text(
                        method.account ?? method.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CustomTextStyles.destinationTitle,
                      ),
                      if (method.account != null) ...[
                        SizedBox(height: 4.v),
                        Text(method.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomTextStyles.destinationSubtitle),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (method != PayoutMethod.values.last) SizedBox(width: 8.h),
          ],
        ],
      ),
    );
  }
}
