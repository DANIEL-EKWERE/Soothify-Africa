import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/app_export.dart';
import '../data/services/video_pip_service.dart';

/// The video that is still playing after its screen closed, in a small
/// window the user can drag, tap to reopen, or close.
///
/// Sized from the video's own aspect so a portrait clip is not letterboxed
/// into a landscape box.
class VideoPipWindow extends StatefulWidget {
  const VideoPipWindow({super.key, required this.bounds});

  /// The area it may be dragged within — the overlay's, less the nav bar.
  final Size bounds;

  /// The window's long edge. The short one follows the video's aspect.
  static const double span = 176;

  @override
  State<VideoPipWindow> createState() => _VideoPipWindowState();
}

class _VideoPipWindowState extends State<VideoPipWindow> {
  /// Null until it has been dragged, so the first paint can park it at the
  /// bottom right without knowing the window's height in advance.
  Offset? _at;

  @override
  Widget build(BuildContext context) {
    final player = videoPip.player.value;
    if (player == null || !player.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final aspect = player.value.aspectRatio;
    final width = VideoPipWindow.span.h;
    final height = width / (aspect > 0 ? aspect : 16 / 9);
    final margin = 16.h;
    final parked = Offset(
      widget.bounds.width - width - margin,
      widget.bounds.height - height - margin,
    );
    final at = _at ?? parked;

    return Positioned(
      left: at.dx,
      top: at.dy,
      child: GestureDetector(
        onPanUpdate: (drag) => setState(() {
          final next = at + drag.delta;
          _at = Offset(
            next.dx.clamp(margin, widget.bounds.width - width - margin),
            next.dy.clamp(margin, widget.bounds.height - height - margin),
          );
        }),
        onTap: _reopen,
        child: Material(
          color: appTheme.transparent,
          child: Container(
            width: width,
            height: height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.h),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: player.value.size.width,
                    height: player.value.size.height,
                    child: VideoPlayer(player),
                  ),
                ),
                // Pause and close, on a wash dark enough to read against a
                // bright frame of video.
                Positioned(
                  top: 4.v,
                  right: 4.h,
                  child: Row(
                    children: [
                      _Control(
                        icon: player.value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onTap: () async {
                          player.value.isPlaying
                              ? await player.pause()
                              : await player.play();
                          if (mounted) setState(() {});
                        },
                      ),
                      SizedBox(width: 4.h),
                      _Control(icon: Icons.close_rounded, onTap: videoPip.close),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Back to the full screen, which takes the player with it.
  void _reopen() {
    final item = videoPip.item.value;
    if (item == null) return;
    Get.toNamed(
      AppRoutes.media,
      arguments: {'item': item, 'source': videoPip.source},
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 26.h,
        height: 26.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16.h, color: Colors.white),
      ),
    );
  }
}
