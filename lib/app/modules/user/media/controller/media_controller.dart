import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';

/// Backs the media detail screen — Figma "Meditation" (135:12484, and
/// 135:12373 for the not-yet-playing preview state).
///
/// It plays now. The frame's 2:34 of 15:00 was a drawing; the bar shows the
/// player's own position, and what the Profile tab counts as meditation
/// minutes is what this reports when a listen ends.
class MediaController extends BaseController {
  MediaController(
    this.item,
    this._content, {
    required this.source,
    AudioPlayer? player,
  }) : _given = player;

  final AudioPlayer? _given;

  /// Passed in rather than refetched: every card that opens this screen
  /// already holds the item, and refetching would blank the page on open.
  final MediaItem item;

  final ContentRepository _content;

  /// The shelf the card was tapped on — the frame's header shows it ("Top
  /// Picks for you", "Sleep Stories"), so it belongs to the caller.
  final String source;

  /// Built on first use, not in the constructor: a screen opened to look at
  /// (a golden, a preview) should not start an audio engine, and an item
  /// with nothing to play never touches this at all.
  late final AudioPlayer _player = _given ?? AudioPlayer();

  /// Whether the player was ever built, so disposing does not create one.
  bool _playerBuilt = false;

  final Rx<Duration> position = Duration.zero.obs;
  final RxBool playing = false.obs;

  /// What the rating stands at. Starts as the item's own and moves when this
  /// person rates it.
  late final RxDouble rating = item.rating.obs;

  /// True once the file is open.
  final RxBool ready = false.obs;

  /// How far the listen got, in whole seconds, at its furthest. Skipping
  /// back and forth should not count the same minute twice.
  int _furthest = 0;

  /// Whether this listen has been reported, so leaving the screen after it
  /// finished does not report it again.
  bool _reported = false;

  final List<StreamSubscription<dynamic>> _watching = [];

  @override
  void onInit() {
    super.onInit();
    _open();
  }

  /// The URL is signed and short-lived, which is why it is played and not
  /// kept: it is the server's permission to hear this, not an address.
  Future<void> _open() async {
    if (item.remoteUrl.isEmpty) {
      // Members-only content the server declined to hand over, or an item
      // with no file. Nothing is said here: this runs while the screen is
      // being built, and a snackbar raised mid-build is a crash. The play
      // button says it, which is when somebody is actually asking.
      return;
    }

    _playerBuilt = true;
    _watching.add(_player.positionStream.listen((at) {
      position.value = at;
      if (at.inSeconds > _furthest) _furthest = at.inSeconds;
    }));
    _watching.add(_player.playerStateStream.listen((state) {
      playing.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _report(completed: true);
      }
    }));

    final opened = await guard(() async {
      await _player.setUrl(item.remoteUrl);
      return true;
    });
    ready.value = opened == true;
  }

  Duration get total {
    final known = _playerBuilt ? _player.duration : null;
    // The item's own length until the file says otherwise: the screen draws
    // a progress bar before the first byte arrives.
    return known != null && known > Duration.zero ? known : item.duration;
  }

  double get progress => total.inSeconds == 0
      ? 0
      : (position.value.inSeconds / total.inSeconds).clamp(0.0, 1.0);

  String get elapsedLabel => '${_mmss(position.value)} / ${_mmss(total)}';

  static String _mmss(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  /// The frame prints "15 mins" beside the rating.
  String get durationLabel => '${total.inMinutes} mins';

  String get ratingLabel =>
      '${rating.value == 0 ? '—' : rating.value.toStringAsFixed(1)}/5';

  Future<void> togglePlay() async {
    if (item.remoteUrl.isEmpty || !_playerBuilt) {
      AppFeedback.info('This one is not available to play on your plan yet.');
      return;
    }
    if (_player.playing) {
      await _player.pause();
      // Reported on pause as well as at the end: somebody who listens for
      // ten minutes and stops has meditated for ten minutes.
      await _report();
      return;
    }
    await guard(() async {
      await _player.play();
      return true;
    });
  }

  Future<void> seekBy(Duration delta) async {
    final next = position.value + delta;
    final target = next < Duration.zero
        ? Duration.zero
        : (next > total ? total : next);
    position.value = target;
    if (ready.value) await _player.seek(target);
  }

  /// One to five stars, kept by the server against this person — rating it
  /// again changes their score rather than adding a second one.
  Future<void> rate(int stars) async {
    final average = await guard(() => _content.rate(item.id, stars));
    if (average == null) return;
    rating.value = average;
    AppFeedback.info('Thanks — that helps us recommend better.');
  }

  void addNote() => Get.toNamed(AppRoutes.journalCompose);

  /// Tells the server what was listened to.
  ///
  /// Quietly: a counter that could not be filed is not worth interrupting a
  /// meditation for, and it is tried again on the next listen.
  Future<void> _report({bool completed = false}) async {
    if (_reported || _furthest <= 0) return;
    _reported = true;
    try {
      await _content.recordPlay(
        item.id,
        secondsListened: _furthest,
        completed: completed,
      );
    } on AppException {
      _reported = false;
    }
  }

  @override
  void onClose() {
    // Leaving mid-listen still counts what was heard.
    _report();
    for (final subscription in _watching) {
      subscription.cancel();
    }
    if (_playerBuilt) _player.dispose();
    super.onClose();
  }
}
