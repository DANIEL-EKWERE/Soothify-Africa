import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import '../../data/models/studio_partner.dart';
import 'controller/partner_controller.dart';
import 'widgets/partner_chrome.dart';

/// The Studio Partner portal — Figma "Studio partner portal · Overview"
/// (`4968:32935`) and "· Active Guest List" (`4968:32751`).
///
/// One screen, two tabs: the frames share a header, the metrics bar and the
/// tab control, and differ only below them. Measured from the frames — the
/// header at 69, metrics at 137 (two 167x85 counts over a 342x115 payout
/// card), the tabs at 369, and the content from 442.
class PartnerPortalScreen extends GetView<PartnerController> {
  const PartnerPortalScreen({super.key, this.now});

  /// The clock the screen reads, for the date over the door list and for
  /// "4 minutes ago" under a request.
  ///
  /// Injected by the tests. Live it is null and [DateTime.now] is used.
  /// Without this seam the goldens here record whatever day they were
  /// taken on and fail every day after -- which is what they were doing.
  final DateTime Function()? now;

  /// Reads the injected clock where a test gave one.
  ///
  /// Static and passed down rather than read off `controller`, because the
  /// pieces that need it are private widgets built from a const
  /// constructor and cannot reach the screen above them otherwise.
  static DateTime Function() clockOf(BuildContext context) {
    final screen = context.findAncestorWidgetOfExactType<PartnerPortalScreen>();
    return screen?.now ?? DateTime.now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.background,
      body: SafeArea(
        child: Obx(
          () => RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                PartnerHeader(
                  studioName: controller.overview.value?.studioName ?? '',
                ),
                SizedBox(height: 24.v),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.h),
                  child: PartnerMetrics(overview: controller.overview.value),
                ),
                SizedBox(height: 24.v),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.h),
                  child: const PartnerTabs(),
                ),
                SizedBox(height: 24.v),
                Padding(
                  padding: EdgeInsets.fromLTRB(24.h, 0, 24.h, 32.v),
                  child: switch (controller.tab.value) {
                    PartnerTab.overview => const _Overview(),
                    PartnerTab.guests => const _GuestList(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Real-Time Notifications" — the requests waiting to be answered.
class _Overview extends StatelessWidget {
  const _Overview();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartnerController>();
    // Its own Obx, not the screen's: this widget is `const` and takes no
    // arguments, so Dart hands back the same instance every rebuild and
    // Flutter skips the child altogether. Without this the feed kept
    // whatever it drew on the first frame — an empty list, before the
    // requests had landed.
    return Obx(() {
      final pending = controller.pending;
      return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('partner.realTime'.tr,
                  style: CustomTextStyles.partnerSection),
            ),
            Container(
              width: 6.h,
              height: 6.h,
              decoration: BoxDecoration(
                color: appTheme.partnerOkInk,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 5.h),
            Text('partner.live'.tr,
                style: CustomTextStyles.partnerStatus
                    .copyWith(color: appTheme.partnerOkInk)),
          ],
        ),
        SizedBox(height: 16.v),
        Text(controller.feedSummary, style: CustomTextStyles.partnerMeta),
        SizedBox(height: 16.v),
        if (pending.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32.v),
            child: Text(
              // Not an error state: a studio that has answered everything
              // should be told so rather than shown an empty box.
              'Nothing waiting. New requests appear here as they come in.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.partnerMeta,
            ),
          )
        else
          for (final request in pending) ...[
            _RequestCard(request: request),
            SizedBox(height: 12.v),
          ],
        SizedBox(height: 4.v),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded,
                size: 13.h, color: appTheme.partnerMuted),
            SizedBox(width: 6.h),
            Text('partner.bookingsLive'.tr,
                style: CustomTextStyles.partnerMeta),
          ],
        ),
      ],
      );
    });
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final StudioBookingRequest request;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartnerController>();
    final when = DateFormat('MMM d, h:mm a').format(request.startsAt);
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32.h,
                height: 32.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.soothifyBlue,
                  borderRadius: BorderRadius.circular(10.h),
                ),
                child: Icon(Icons.notifications_none_rounded,
                    size: 18.h, color: appTheme.onPrimary),
              ),
              SizedBox(width: 10.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('partner.newBooking'.tr,
                        style: CustomTextStyles.partnerCardTitle),
                    SizedBox(height: 2.v),
                    Text(
                      '${_ago(request.receivedAt, PartnerPortalScreen.clockOf(context))} · '
                      '${DateFormat('MMM d').format(request.receivedAt)}',
                      style: CustomTextStyles.partnerMeta,
                    ),
                  ],
                ),
              ),
              if (request.unread)
                Container(
                  width: 6.h,
                  height: 6.h,
                  margin: EdgeInsets.only(top: 6.v),
                  decoration: BoxDecoration(
                    color: appTheme.soothifyBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.v),
          Text(
            'User: ${request.guestName} | Class: ${request.className} | $when',
            style: CustomTextStyles.partnerCardBody,
          ),
          SizedBox(height: 10.v),
          Text(
            'Type: ${request.sessionType} (Wholesale Floor Payout: '
            '₦${_grouped(request.payoutNaira)})',
            style: CustomTextStyles.partnerMeta,
          ),
          SizedBox(height: 12.v),
          Align(
            alignment: Alignment.centerLeft,
            child: PartnerStatusPill(
              label: 'Status: ${request.status.label}',
              good: false,
            ),
          ),
          SizedBox(height: 16.v),
          Obx(() {
            final busy = controller.busyId.value == request.id;
            return Row(
              children: [
                SizedBox(
                  width: 88.h,
                  height: 44.v,
                  child: _Action(
                    label: 'Decline',
                    filled: false,
                    onTap: busy ? null : () => controller.decline(request),
                  ),
                ),
                SizedBox(width: 8.h),
                Expanded(
                  child: SizedBox(
                    height: 44.v,
                    child: _Action(
                      label: request.acceptLabel,
                      filled: true,
                      busy: busy,
                      onTap: busy ? null : () => controller.accept(request),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// "Just now", "4 minutes ago" — the frame's own two forms.
  static String _ago(DateTime at, DateTime Function() now) {
    final minutes = now().difference(at).inMinutes;
    if (minutes < 1) return 'Just now';
    if (minutes == 1) return '1 minute ago';
    if (minutes < 60) return '$minutes minutes ago';
    final hours = minutes ~/ 60;
    return hours == 1 ? '1 hour ago' : '$hours hours ago';
  }

  static String _grouped(int naira) {
    final digits = naira.toString();
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return out.toString();
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.label,
    required this.filled,
    required this.onTap,
    this.busy = false,
  });

  final String label;
  final bool filled;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.h),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? appTheme.soothifyBlue : appTheme.surface,
          borderRadius: BorderRadius.circular(10.h),
          border: filled ? null : Border.all(color: appTheme.cardRim),
        ),
        child: busy
            ? SizedBox(
                height: 18.h,
                width: 18.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.h,
                  color: appTheme.onPrimary,
                ),
              )
            : Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.partnerMeta.copyWith(
                  color: filled ? appTheme.onPrimary : appTheme.soothifyBlue,
                ),
              ),
      ),
    );
  }
}

/// "Today's Guests" — the door list.
class _GuestList extends StatelessWidget {
  const _GuestList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartnerController>();
    // Its own Obx, for the reason _Overview has one.
    return Obx(() {
      final guests = controller.visibleGuests;
      return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('partner.todaysGuests'.tr,
                  style: CustomTextStyles.partnerSection),
            ),
            Icon(Icons.calendar_today_outlined,
                size: 14.h, color: appTheme.partnerMuted),
            SizedBox(width: 6.h),
            Text(
                DateFormat('MMM d, yyyy')
                    .format(PartnerPortalScreen.clockOf(context)()),
                style: CustomTextStyles.partnerMeta),
          ],
        ),
        SizedBox(height: 16.v),
        Container(
          height: 44.v,
          padding: EdgeInsets.symmetric(horizontal: 12.h),
          decoration: BoxDecoration(
            color: appTheme.surface,
            borderRadius: BorderRadius.circular(10.h),
            border: Border.all(color: appTheme.cardRim),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 18.h, color: appTheme.partnerMuted),
              SizedBox(width: 8.h),
              Expanded(
                child: TextField(
                  onChanged: controller.search,
                  style: CustomTextStyles.partnerCardBody,
                  cursorColor: appTheme.soothifyBlue,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Search by guest name or booking ID',
                    hintStyle: CustomTextStyles.partnerMeta,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.v),
        Row(
          children: [
            for (final (f, label) in [
              (GuestFilter.all, 'All (${controller.guests.length})'),
              (GuestFilter.checkedIn, 'Checked In (${controller.checkedIn})'),
              (GuestFilter.awaiting, 'Awaiting Arrival (${controller.awaiting})'),
            ]) ...[
              _FilterChip(label: label, filter: f),
              SizedBox(width: 6.h),
            ],
          ],
        ),
        SizedBox(height: 16.v),
        if (guests.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32.v),
            child: Text(
              'Nobody matches that.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.partnerMeta,
            ),
          )
        else
          for (final guest in guests) ...[
            _GuestCard(guest: guest),
            SizedBox(height: 8.v),
          ],
        SizedBox(height: 8.v),
        Text(controller.listSummary,
            style: CustomTextStyles.partnerMeta),
      ],
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.filter});

  final String label;
  final GuestFilter filter;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartnerController>();
    final chosen = controller.filter.value == filter;
    return GestureDetector(
      onTap: () => controller.choose(filter),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 30.v,
        padding: EdgeInsets.symmetric(horizontal: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: chosen ? appTheme.soothifyBlue : appTheme.surface,
          borderRadius: BorderRadius.circular(8.h),
          border: chosen ? null : Border.all(color: appTheme.cardRim),
        ),
        child: Text(
          label,
          style: CustomTextStyles.partnerStatus.copyWith(
            color: chosen ? appTheme.onPrimary : appTheme.partnerMuted,
          ),
        ),
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({required this.guest});

  final StudioGuest guest;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PartnerController>();
    final arrived = guest.arrival == StudioArrival.checkedIn;
    return Container(
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        color: appTheme.surface,
        borderRadius: BorderRadius.circular(12.h),
        border: Border.all(color: appTheme.cardRim),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38.h,
                height: 38.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: appTheme.soothifyBlue,
                  shape: BoxShape.circle,
                ),
                child: Text(guest.initials,
                    style: CustomTextStyles.partnerInitials),
              ),
              SizedBox(width: 10.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guest.name,
                        style: CustomTextStyles.partnerCardBody),
                    SizedBox(height: 4.v),
                    Text(
                      '${guest.className} · '
                      '${DateFormat('h:mm a').format(guest.startsAt)}',
                      style: CustomTextStyles.partnerMeta,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.v),
          Row(
            children: [
              // The whole QR row admits the guest: a door with a scanner
              // taps the code, a door without one taps the row.
              Obx(() {
                final busy = controller.busyId.value == guest.id;
                return GestureDetector(
                  onTap: arrived ? null : () => controller.checkIn(guest),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 32.h,
                    height: 32.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appTheme.soothifyBlue,
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                    child: busy
                        ? SizedBox(
                            height: 14.h,
                            width: 14.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.h,
                              color: appTheme.onPrimary,
                            ),
                          )
                        : Icon(Icons.qr_code_2_rounded,
                            size: 20.h, color: appTheme.onPrimary),
                  ),
                );
              }),
              SizedBox(width: 10.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arrived && guest.verifiedAt != null
                          ? 'QR verified · '
                              '${DateFormat('h:mm a').format(guest.verifiedAt!)}'
                          : 'QR generated',
                      style: CustomTextStyles.partnerMeta,
                    ),
                    SizedBox(height: 2.v),
                    Text(guest.code, style: CustomTextStyles.partnerMeta),
                  ],
                ),
              ),
              PartnerStatusPill(label: guest.arrival.label, good: arrived),
            ],
          ),
        ],
      ),
    );
  }
}
