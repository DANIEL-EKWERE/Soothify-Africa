import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../data/models/bank_destination.dart';
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
                            controller.chosenDestination.refresh();
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
                      padding: EdgeInsets.symmetric(horizontal: 14.h),
                      decoration: BoxDecoration(
                        color: appTheme.policyPanel,
                        borderRadius: BorderRadius.circular(24.h),
                      ),
                      // `widthFactor: 1`, not `alignment: center` on the
                      // Container: an aligned Container expands to its
                      // constraints, and the frame's pill hugs its words.
                      child: Center(
                        widthFactor: 1,
                        child: Text('How much do you want to withdraw',
                            style: CustomTextStyles.withdrawPrompt),
                      ),
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
                // "Withdraw", not "Proceed": the frame labels it for the
                // thing it does, and it ends on the confirmation rather than
                // doubling back to the method chooser.
                () => CustomElevatedButton(
                  text: 'Withdraw',
                  isEnabled: controller.canProceed,
                  onPressed: controller.withdraw,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One 109x86 tile per account on file, the chosen one outlined in blue.
///
/// The frame draws three, which is three saved accounts rather than three
/// payment methods: the row grows and shrinks with what the expert has
/// added, and scrolls sideways past the three the frame had room for.
class _DestinationTiles extends StatelessWidget {
  const _DestinationTiles();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayoutController>();
    return Obx(() {
      final destinations = controller.destinations;
      if (destinations.isEmpty) {
        // Unreachable from Withdraw — that button sends an expert with no
        // account to the chooser instead — but the screen is a route, and a
        // route can be opened directly.
        return _AddFirstDestination(onTap: controller.addDestination);
      }
      return SizedBox(
        height: 86.v,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: destinations.length,
          separatorBuilder: (_, _) => SizedBox(width: 8.h),
          itemBuilder: (context, i) => _DestinationTile(
            destination: destinations[i],
            selected: controller.chosenDestination.value == i,
            onTap: () => controller.chooseDestination(i),
          ),
        ),
      );
    });
  }
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final BankDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 109.h,
        padding: EdgeInsets.all(9.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          // Unselected tiles take the card rim, not a near-black outline.
          border: Border.all(
            color: selected ? appTheme.soothifyBlue : appTheme.cardRim,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24.h,
              height: 24.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.textPrimary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              // The frame puts an institution mark here. The bank logos were
              // never exported, so this stands in.
              child: Icon(Icons.account_balance,
                  size: 13.h, color: appTheme.textPrimary),
            ),
            const Spacer(),
            Text(
              destination.bank,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CustomTextStyles.destinationTitle,
            ),
            SizedBox(height: 4.v),
            Text(BankDestination.kind,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.destinationSubtitle),
          ],
        ),
      ),
    );
  }
}

/// Stands in for the row when there is nothing to withdraw into.
class _AddFirstDestination extends StatelessWidget {
  const _AddFirstDestination({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 86.v,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.soothifyBlue),
        ),
        child: Text('+  Add a payout account',
            style: CustomTextStyles.subscribeLabel
                .copyWith(color: appTheme.soothifyBlue)),
      ),
    );
  }
}
