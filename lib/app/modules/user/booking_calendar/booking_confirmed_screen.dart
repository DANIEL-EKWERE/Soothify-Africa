import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../data/models/booked_slot.dart';
import '../../../widgets/gradient_text.dart';

/// "Your live session has been scheduled successfully" — the end of the
/// booking chain, redrawn by the designer on 2026-10-05.
///
/// The frame carries no button: a handshake over the pale brand circle and
/// three centred lines in the title gradient, under the same "Schedule"
/// header the payment screen uses. So it takes itself off after a beat, and
/// says so while it counts down.
///
/// Measured below the status bar: the illustration 117 across at 249.5, and
/// the three lines on a 26 pitch from 404.
class BookingConfirmedScreen extends StatefulWidget {
  const BookingConfirmedScreen({super.key});

  /// How long the screen stands before it returns to the app.
  static const countdown = Duration(seconds: 3);

  static const message = 'Your live session has been scheduled successfully. '
      'We’re looking forward to supporting your journey';

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  late int _left = BookingConfirmedScreen.countdown.inSeconds;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_left <= 1) {
        _tick?.cancel();
        _home();
        return;
      }
      setState(() => _left -= 1);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _home() {
    _tick?.cancel();
    Get.until((route) => Get.currentRoute == AppRoutes.shell);
  }

  @override
  Widget build(BuildContext context) {
    final booked = Get.arguments is BookedSlot ? Get.arguments as BookedSlot : null;
    return PopScope(
      // The receipt behind this is paid for and done with; stepping back onto
      // it would offer to pay again.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _home();
      },
      child: Scaffold(
        backgroundColor: appTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 22.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.h),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _home,
                      child: CustomImageView(
                        imagePath: ImageConstant.icBack,
                        height: 18.h,
                        width: 18.h,
                        color: appTheme.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Schedule',
                        textAlign: TextAlign.center,
                        style: CustomTextStyles.appBarTitle,
                      ),
                    ),
                    SizedBox(width: 18.h),
                  ],
                ),
              ),
              SizedBox(height: 199.v),
              Container(
                height: 117.h,
                width: 117.h,
                alignment: Alignment.center,
                // The pale disc is the frame's, not the artwork's: the PNG is
                // transparent behind the handshake.
                decoration: BoxDecoration(
                  color: appTheme.brandWash,
                  shape: BoxShape.circle,
                ),
                child: CustomImageView(
                  imagePath: ImageConstant.imgSessionBooked,
                  height: 117.h,
                  width: 117.h,
                ),
              ),
              SizedBox(height: 38.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.h),
                child: GradientText(
                  BookingConfirmedScreen.message,
                  gradient: appTheme.titleGradient,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.bookedMessage,
                ),
              ),
              if (booked != null) ...[
                SizedBox(height: 18.v),
                Text(
                  booked.summary,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.bookedWhen,
                ),
              ],
              const Spacer(),
              Text(
                'Redirecting you back to home in $_left sec',
                textAlign: TextAlign.center,
                style: CustomTextStyles.redirectNote,
              ),
              SizedBox(height: 32.v),
            ],
          ),
        ),
      ),
    );
  }
}
