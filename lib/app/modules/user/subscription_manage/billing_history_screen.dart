import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/membership.dart';
import '../settings/widgets/settings_header.dart';
import 'controller/subscription_manage_controller.dart';

/// "Billing History" — Figma `308:25859`, with the empty state from
/// `308:25844`.
///
/// Measured below the status bar: title 65, subtitle 127, the first row at
/// 189 (342 wide, 16 radius, 5% hairline), 16 between rows. The empty state
/// is one card 246 tall with a 64 circle above its copy.
class BillingHistoryScreen extends GetView<SubscriptionManageController> {
  const BillingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SettingsHeader(title: 'Billing History'),
            SizedBox(height: 38.v),
            Expanded(
              child: Obx(() {
                final invoices = controller.invoices;
                return ListView(
                  padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                  children: [
                    Text(
                      'A record of your past payments and active invoices.',
                      style: CustomTextStyles.subscriptionBody,
                    ),
                    SizedBox(height: 24.v),
                    if (invoices.isEmpty)
                      const _NoInvoices()
                    else
                      for (final invoice in invoices) ...[
                        _InvoiceRow(invoice: invoice),
                        SizedBox(height: 16.v),
                      ],
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionManageController>();
    return Container(
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.cardHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  invoice.date,
                  style: CustomTextStyles.subscriptionLabel,
                ),
              ),
              Text(
                invoice.amount,
                style: CustomTextStyles.subscriptionAmount,
              ),
            ],
          ),
          SizedBox(height: 18.v),
          Text(
            invoice.description,
            style: CustomTextStyles.subscriptionPlanName,
          ),
          SizedBox(height: 16.v),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 26.v,
              padding: EdgeInsets.symmetric(horizontal: 10.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appTheme.statusLiveInk.withValues(alpha: 0.26),
                borderRadius: BorderRadius.circular(16.h),
              ),
              child: Text(
                invoice.status,
                style: CustomTextStyles.subscriptionBadge
                    .copyWith(color: appTheme.statusLiveInk),
              ),
            ),
          ),
          SizedBox(height: 20.v),
          Center(
            child: InkWell(
              onTap: () => controller.downloadInvoice(invoice),
              child: Text(
                'Download PDF',
                style: CustomTextStyles.subscriptionLink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nothing billed yet — the state a trial sits in.
class _NoInvoices extends StatelessWidget {
  const _NoInvoices();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.h, 40.v, 24.h, 40.v),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(16.h),
        border: Border.all(color: appTheme.cardHairline),
      ),
      child: Column(
        children: [
          Container(
            height: 64.h,
            width: 64.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: appTheme.brandWash,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 30.h,
              color: appTheme.soothifyBlue,
            ),
          ),
          SizedBox(height: 24.v),
          Text(
            'No past invoices yet.',
            textAlign: TextAlign.center,
            style: CustomTextStyles.subscriptionHeadline,
          ),
          SizedBox(height: 12.v),
          Text(
            'Your payment receipts will appear here as soon as your first '
            'billing cycle processes.',
            textAlign: TextAlign.center,
            style: CustomTextStyles.subscriptionBody,
          ),
        ],
      ),
    );
  }
}
