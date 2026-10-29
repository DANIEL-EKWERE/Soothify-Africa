import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../../core/app_export.dart';
import '../../../core/base_controller.dart';
import '../../../data/models/call_credentials.dart';
import '../../../data/repositories/booking_repository.dart';

/// The session call itself.
///
/// Until now this was two static screens with buttons that toggled local
/// state: no SDK, no camera, no audio, and two people "in a call" who
/// could not hear each other. The server has minted ZEGOCLOUD tokens all
/// along -- nothing asked it for one.
///
/// Credentials are fetched here, at the moment they are needed. They are
/// issued only to the two people on the booking, only for a confirmed
/// session, and only from fifteen minutes before to fifteen after; the
/// server says so in its own words when it refuses, and that is what is
/// shown.
class SessionCallController extends BaseController {
  SessionCallController(this._bookings, this.sessionId);

  final BookingRepository _bookings;
  final String sessionId;

  final Rxn<CallCredentials> credentials = Rxn<CallCredentials>();

  /// Why the call cannot be joined, in the server's words. Empty while it
  /// is still being asked for, or once it has answered.
  final RxString refusal = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _fetch();
  }

  Future<void> _fetch() async {
    if (sessionId.isEmpty) {
      refusal.value = 'This session could not be identified.';
      return;
    }
    try {
      final given = await _bookings.callToken(sessionId);
      if (!given.isUsable) {
        refusal.value = 'Calls are not configured yet.';
        return;
      }
      credentials.value = given;
    } on AppException catch (error) {
      // The server's own line: "The room opens fifteen minutes before the
      // session", "This session has finished", and so on.
      refusal.value = error.message;
    } catch (error) {
      Log.e('could not get the call credentials', error: error);
      refusal.value = 'We could not start the call just now.';
    }
  }
}

class SessionCallScreen extends GetView<SessionCallController> {
  const SessionCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final given = controller.credentials.value;
      if (given != null) return _Call(credentials: given);

      final why = controller.refusal.value;
      return Scaffold(
        backgroundColor: appTheme.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.h),
              child: why.isEmpty
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          why,
                          textAlign: TextAlign.center,
                          style: CustomTextStyles.emptyStateBody,
                        ),
                        SizedBox(height: 16.v),
                        TextButton(
                          onPressed: Get.back,
                          child: Text(
                            'Go back',
                            style: CustomTextStyles.emptyStateBody.copyWith(
                              color: appTheme.soothifyBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }
}

class _Call extends StatelessWidget {
  const _Call({required this.credentials});

  final CallCredentials credentials;

  @override
  Widget build(BuildContext context) {
    // The config the booking chose: a voice call turns the camera off at
    // the start rather than hiding it, so either side can still turn it on
    // if they agree to.
    final config = credentials.isVideo
        ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

    return ZegoUIKitPrebuiltCall(
      appID: credentials.appId,
      // Signed server-side; the app never holds the secret that makes one.
      token: credentials.token,
      appSign: '',
      userID: credentials.userId,
      userName: credentials.userId,
      callID: credentials.roomId,
      config: config,
      events: ZegoUIKitPrebuiltCallEvents(
        // However it ends -- hung up here, or the other side leaving --
        // the flow behind this takes over and asks how it went. The
        // default action pops a route this screen does not own, so it is
        // not called.
        onCallEnd: (event, defaultAction) => Get.back(result: true),
      ),
    );
  }
}
