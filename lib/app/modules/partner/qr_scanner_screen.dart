import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/app_export.dart';

/// Reads a member's Passport QR at the door — the "Scan Passport QR Code"
/// button on Figma `416:26667`.
///
/// Returns the code it read through `Get.back(result:)`, so the roster can
/// verify it the same way it verifies a typed one. The frame draws no
/// scanner of its own; this is the camera behind its button.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _camera = MobileScannerController(
    // One code at a time, and only QR: a door is not reading barcodes, and
    // narrowing the formats makes it find the right thing faster.
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  /// Latched so a code is handed back once. The detector fires every frame
  /// it can still see the code, and without this the roster would be sent
  /// the same member a dozen times.
  bool _handled = false;

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  void _found(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes
        .map((b) => b.rawValue ?? '')
        .firstWhere((v) => v.trim().isNotEmpty, orElse: () => '');
    if (code.isEmpty) return;
    _handled = true;
    Get.back(result: code.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _camera,
              onDetect: _found,
              errorBuilder: (context, error) => _CameraTrouble(error: error),
            ),
          ),
          // The window the desk aims through.
          Center(
            child: Container(
              width: 240.h,
              height: 240.h,
              decoration: BoxDecoration(
                border: Border.all(color: appTheme.onPrimary, width: 3),
                borderRadius: BorderRadius.circular(16.h),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.h),
                child: Row(
                  children: [
                    _Round(
                      icon: Icons.close,
                      onTap: Get.back,
                    ),
                    const Spacer(),
                    ValueListenableBuilder<MobileScannerState>(
                      valueListenable: _camera,
                      builder: (context, state, _) => _Round(
                        icon: state.torchState == TorchState.on
                            ? Icons.flashlight_on
                            : Icons.flashlight_off,
                        onTap: _camera.toggleTorch,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24.h,
            right: 24.h,
            bottom: 40.v,
            child: SafeArea(
              child: Column(
                children: [
                  Text(
                    'Point the camera at the member’s Passport QR.',
                    textAlign: TextAlign.center,
                    style: CustomTextStyles.partnerCardTitle
                        .copyWith(color: appTheme.onPrimary),
                  ),
                  SizedBox(height: 12.v),
                  // Always offered: a scratched screen or a dark doorway
                  // should not stop somebody getting into class.
                  InkWell(
                    onTap: Get.back,
                    child: Padding(
                      padding: EdgeInsets.all(8.h),
                      child: Text(
                        'Type the entry code instead',
                        style: CustomTextStyles.partnerCardBody
                            .copyWith(color: appTheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40.h,
        height: 40.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20.h, color: Colors.white),
      ),
    );
  }
}

/// Shown when the camera cannot start — refused, missing, or in use.
class _CameraTrouble extends StatelessWidget {
  const _CameraTrouble({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final reason = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        'Soothify needs the camera to read a Passport QR. You can allow '
            'it in Settings, or type the entry code instead.',
      MobileScannerErrorCode.unsupported =>
        'This device cannot scan. Type the entry code instead.',
      _ => 'The camera would not start. Type the entry code instead.',
    };
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.no_photography_outlined,
                  size: 40.h, color: appTheme.onPrimary),
              SizedBox(height: 16.v),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: CustomTextStyles.partnerCardBody
                    .copyWith(color: appTheme.onPrimary),
              ),
              SizedBox(height: 20.v),
              InkWell(
                onTap: Get.back,
                child: Padding(
                  padding: EdgeInsets.all(10.h),
                  child: Text('Back to the desk',
                      style: CustomTextStyles.partnerCardTitle
                          .copyWith(color: appTheme.soothifyBlue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
