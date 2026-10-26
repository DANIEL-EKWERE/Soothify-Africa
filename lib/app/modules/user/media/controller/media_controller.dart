import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/app_export.dart';
import '../../../../core/base_controller.dart';
import '../../../../data/models/media_item.dart';
import '../../../../data/repositories/content_repository.dart';
import '../../../../data/services/video_pip_service.dart';

/// Backs the media detail screen — Figma "Meditation" (135:12484, and
/// 135:12373 for the not-yet-playing preview state).
///
/// It plays now. The frame's 2:34 of 15:00 was a drawing; the bar shows the
/// player's own position, and what the Profile tab counts as meditation
/// minutes is what this reports when a listen ends.
///
/// Two engines behind one set of controls. just_audio plays the audio
/// library; a video needs a surface to draw on, and handing a video file to
/// an audio player is why nothing happened when one was opened. Which engine
/// is in play is [isVideo], and everything above it — play, seek, the
/// position, the reporting — reads the same either way.
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

  /// A video's own player. Null for audio, and until the screen opens one.
  VideoPlayerController? _video;

  /// The surface the screen draws when there is a picture to show.
  VideoPlayerController? get video =>
      _video != null && _video!.value.isInitialized ? _video : null;

  /// Whether this item is watched rather than listened to.
  bool get isVideo => item.type == MediaType.video;

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

    if (isVideo) {
      await _openVideo();
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
      try {
        await _player.setUrl(item.remoteUrl);
      } on PlayerInterruptedException {
        // Leaving the screen while the first bytes are still arriving
        // cancels the load, and just_audio reports that as a thrown
        // exception. Nothing failed — the player is being torn down
        // because nobody is listening any more — so this must not reach
        // guard, which would log it and raise an error snackbar over
        // whatever screen the user moved on to.
        return false;
      }
      return true;
    });
    ready.value = opened == true;
  }

  /// Opens the file on a video surface.
  ///
  /// VideoPlayerController reports through a listener rather than streams,
  /// so position, playing and completion all come off the one tick.
  Future<void> _openVideo() async {
    // The floating window may already be playing this very item: take its
    // player back rather than opening a second one, so reopening the screen
    // carries on from where the window had it.
    final handed = videoPip.release(item.id);
    if (handed == null) {
      // A different video is floating: end it rather than leave it playing
      // unseen behind this screen. The window hides itself here, which
      // would otherwise make it an invisible second soundtrack.
      videoPip.close();
    }
    final player = _video = handed ??
        VideoPlayerController.networkUrl(Uri.parse(item.remoteUrl));
    _playerBuilt = true;
    player.addListener(_onVideoTick);
    if (handed != null) {
      _onVideoTick();
      ready.value = true;
      return;
    }

    final opened = await guard(() async {
      await player.initialize();
      return true;
    });
    // The screen may have gone while the first bytes were arriving.
    if (_video != player) return;
    ready.value = opened == true;
  }

  void _onVideoTick() {
    final player = _video;
    if (player == null || !player.value.isInitialized) return;
    final at = player.value.position;
    position.value = at;
    if (at.inSeconds > _furthest) _furthest = at.inSeconds;
    playing.value = player.value.isPlaying;
    if (player.value.isCompleted) _report(completed: true);
  }

  Duration get total {
    if (isVideo) {
      final known = _video?.value.duration;
      return known != null && known > Duration.zero ? known : item.duration;
    }
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
    if (playing.value) {
      await (isVideo ? _video?.pause() ?? Future.value() : _player.pause());
      // Reported on pause as well as at the end: somebody who listens for
      // ten minutes and stops has meditated for ten minutes.
      await _report();
      return;
    }
    await guard(() async {
      if (isVideo) {
        await _video?.play();
      } else {
        await _player.play();
      }
      return true;
    });
  }

  /// Straight to a point, for the scrub bar. [seekBy] is the ±10 buttons.
  Future<void> seekTo(Duration target) async {
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > total ? total : target);
    position.value = clamped;
    if (!ready.value) return;
    if (isVideo) {
      await _video?.seekTo(clamped);
    } else {
      await _player.seek(clamped);
    }
  }

  Future<void> seekBy(Duration delta) async {
    final next = position.value + delta;
    final target = next < Duration.zero
        ? Duration.zero
        : (next > total ? total : next);
    position.value = target;
    if (!ready.value) return;
    if (isVideo) {
      await _video?.seekTo(target);
    } else {
      await _player.seek(target);
    }
  }

  /// What this person gave it, 0 until they do. Distinct from [rating],
  /// which is everybody's average and is what the meta line prints.
  final RxInt myRating = 0.obs;

  /// True while a rating is in flight, so the row cannot be tapped into a
  /// second request before the first has answered.
  final RxBool sending = false.obs;

  /// One to five stars, kept by the server against this person — rating it
  /// again changes their score rather than adding a second one.
  Future<void> rate(int stars) async {
    if (sending.value) return;
    sending.value = true;
    // Filled straight away: the request is a round trip, and a star that
    // only lights once the server answers reads as a tap that missed.
    final was = myRating.value;
    myRating.value = stars;
    final average = await guard(
      () => _content.rate(item.id, stars),
      setLoading: false,
    );
    sending.value = false;
    if (average == null) {
      // guard has already said so; put the row back to what the server
      // still holds rather than leaving a score that did not take.
      myRating.value = was;
      return;
    }
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
    final video = _video;
    _video = null;
    if (video != null) {
      video.removeListener(_onVideoTick);
      if (video.value.isInitialized && video.value.isPlaying) {
        // Still playing when the screen went: hand it to the floating
        // window rather than ending it. Leaving halfway through a video
        // used to stop it dead.
        videoPip.adopt(video, item, from: source);
      } else {
        video.dispose();
      }
    } else if (_playerBuilt) {
      _player.dispose();
    }
    super.onClose();
  }
}
