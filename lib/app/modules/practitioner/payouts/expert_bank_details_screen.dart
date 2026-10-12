import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../widgets/expert_header.dart';
import 'controller/payout_controller.dart';
import 'expert_payout_method_screen.dart' show Assurance;

/// Where a bank transfer should land — Figma "Bank GTransfer Details".
///
/// The frame's own title carries a stray G; corrected here, as the other
/// typos in this file are.
///
/// Three fields: the bank as a picker, then the account number and the name
/// on it. Add Bank Details is dead until all three are given — the frame
/// draws it filled, but saving an empty destination is how money goes
/// missing.
class ExpertBankDetailsScreen extends GetView<PayoutController> {
  const ExpertBankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33.v),
            const ExpertHeader(title: 'Bank Transfer Details'),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.h, 25.v, 24.h, 24.v),
                children: [
                  Text(
                    'Enter your bank account details to receive payment in '
                    'Nigerian Naira (NGN)',
                    style: CustomTextStyles.expertBlurb,
                  ),
                  SizedBox(height: 32.v),
                  Text('Bank Name', style: CustomTextStyles.expertFieldLabel),
                  SizedBox(height: 8.v),
                  Obx(() => _BankPicker(
                        value: controller.bank.value,
                        onPick: () => _pickBank(context),
                      )),
                  SizedBox(height: 24.v),
                  Text('Account Number',
                      style: CustomTextStyles.expertFieldLabel),
                  SizedBox(height: 8.v),
                  _Field(
                    controller: controller.accountNumber,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => controller.touchBank(),
                  ),
                  SizedBox(height: 24.v),
                  Text('Account Name',
                      style: CustomTextStyles.expertFieldLabel),
                  SizedBox(height: 8.v),
                  _Field(
                    controller: controller.accountName,
                    onChanged: (_) => controller.touchBank(),
                  ),
                  SizedBox(height: 32.v),
                  const Assurance(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 25.v),
              child: Obx(
                () => CustomElevatedButton(
                  text: 'Add Bank Details',
                  isEnabled: controller.canSaveBank,
                  onPressed: controller.saveBankDetails,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBank(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: appTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16.h)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 16.v),
          children: [
            for (final bank in PayoutController.banks)
              ListTile(
                title: Text(bank, style: CustomTextStyles.expertRowLabel),
                onTap: () => Navigator.of(context).pop(bank),
              ),
          ],
        ),
      ),
    );
    if (picked != null) controller.chooseBank(picked);
  }
}

/// The bank field. A picker rather than a text box: a mistyped bank name is
/// a failed transfer, and the list is short and fixed.
class _BankPicker extends StatelessWidget {
  const _BankPicker({required this.value, required this.onPick});

  final String value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(8.h),
      child: Container(
        height: 56.v,
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        decoration: BoxDecoration(
          color: appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: Border.all(color: appTheme.fieldRim),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? 'Select Bank' : value,
                style: value.isEmpty
                    ? CustomTextStyles.expertFieldHint
                    : CustomTextStyles.expertRowLabel,
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                size: 24.h, color: appTheme.textPrimary),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.onChanged,
    this.keyboardType,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.v,
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(8.h),
        border: Border.all(color: appTheme.fieldRim),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: CustomTextStyles.expertRowLabel,
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            // The app's input theme fills its fields; this one is already
            // inside a white box, and the fill was drawing a second box
            // inside the first.
            filled: false,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
