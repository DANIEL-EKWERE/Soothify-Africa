import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/initial_bindings.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/services/ambience_service.dart';
import 'package:soothifyafrica/app/data/services/language_service.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/data/services/theme_service.dart';
import 'package:soothifyafrica/app/routes/app_pages.dart';
import 'package:soothifyafrica/app/routes/app_routes.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/modules/auth/splash/splash_screen.dart';

import 'helpers.dart';

/// The stream that fades up under the splash's breathing prompts.
///
/// The player itself cannot run here -- there is no audio platform in a
/// widget test -- so what is checked is the shape: that it starts silent,
/// arrives at full when the first prompt does, holds, and leaves gently.
/// A fake player records the volumes it is handed.
class _FakePlayer extends Fake implements AudioPlayer {
  final List<double> volumes = [];
  String? asset;
  LoopMode? loop;
  int plays = 0;
  int stops = 0;
  int disposals = 0;

  /// Thrown by [setAsset], for the missing-file path.
  Object? failWith;

  @override
  Future<Duration?> setAsset(
    String asset, {
    bool preload = true,
    Duration? initialPosition,
    String? package,
    dynamic tag,
  }) async {
    if (failWith != null) throw failWith!;
    this.asset = asset;
    return const Duration(seconds: 18);
  }

  @override
  Future<void> setLoopMode(LoopMode mode) async => loop = mode;

  @override
  Future<void> setVolume(double volume) async => volumes.add(volume);

  @override
  Future<void> play() async => plays++;

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> dispose() async => disposals++;
}

/// Starts the service with its fade under the test's own clock.
///
/// `tester.runAsync` would let the player's futures complete, but it also
/// creates the fade's periodic timer in the real zone, where `tester.pump`
/// cannot advance it -- the volume then sits at zero for the whole test. The
/// fake player answers immediately, so an unawaited start and a
/// zero-duration pump is enough to get past its awaits while leaving the
/// timer where the clock can reach it.
/// The fade-out, run to completion.
///
/// A periodic timer at 40ms needs `ceil(duration / 40)` ticks, which is a
/// fraction longer than the duration itself -- pumping exactly [fadeOut]
/// leaves the last tick pending, and a pending timer at the end of a widget
/// test is a failure whatever the test was actually checking.
Future<void> drainFade(WidgetTester tester) =>
    tester.pump(AmbienceService.fadeOut + const Duration(milliseconds: 200));

Future<void> startUnderFakeClock(
  WidgetTester tester,
  AmbienceService ambience,
) async {
  unawaited(ambience.start());
  await tester.pump();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefUtils().init();
  });
  tearDown(Get.reset);

  group('the asset', () {
    test('is the one the service asks for', () async {
      // The bundle is what a widget test can see of the asset list, so a
      // file renamed or dropped from pubspec fails here rather than in
      // silence on a phone.
      final bytes = await rootBundle.load(AmbienceService.asset);
      expect(bytes.lengthInBytes, greaterThan(10000));
    });
  });

  group('AmbienceService', () {
    late _FakePlayer player;
    late AmbienceService ambience;

    setUp(() {
      player = _FakePlayer();
      ambience = AmbienceService(player: player);
    });

    test('starts silent, playing, and looped', () async {
      await ambience.start();

      expect(player.asset, AmbienceService.asset);
      expect(player.plays, 1);
      expect(player.loop, LoopMode.all);
      // The very first volume set is zero: a stream that began at full
      // would be a bang, not a fade.
      expect(player.volumes.first, 0);
    });

    testWidgets('it arrives at full as the first prompt does', (tester) async {
      await startUnderFakeClock(tester, ambience);

      // The fade runs for exactly one word-swap.
      expect(AmbienceService.fadeIn, SplashScreen.fade);

      // Half way: audibly there, not yet at full.
      await tester.pump(SplashScreen.fade ~/ 2);
      expect(ambience.volume, greaterThan(0));
      expect(ambience.volume, lessThan(AmbienceService.peak));

      await tester.pump(SplashScreen.fade);
      expect(ambience.volume, closeTo(AmbienceService.peak, 0.001));
      expect(ambience.isFading, isFalse);
    });

    testWidgets('the fade only ever climbs on the way up', (tester) async {
      await startUnderFakeClock(tester, ambience);
      await tester.pump(SplashScreen.fade + const Duration(seconds: 1));

      for (var i = 1; i < player.volumes.length; i++) {
        expect(
          player.volumes[i],
          greaterThanOrEqualTo(player.volumes[i - 1]),
          reason: 'volume dipped at step $i: ${player.volumes}',
        );
      }
    });

    testWidgets('it holds for three seconds after the handoff',
        (tester) async {
      await startUnderFakeClock(tester, ambience);
      await tester.pump(SplashScreen.fade);
      expect(ambience.volume, closeTo(AmbienceService.peak, 0.001));

      ambience.land();

      // Still at full a moment before the hold is up.
      await tester.pump(AmbienceService.hold - const Duration(milliseconds: 200));
      expect(ambience.volume, closeTo(AmbienceService.peak, 0.001));

      // And on its way down a moment after.
      await tester.pump(const Duration(milliseconds: 400));
      expect(ambience.volume, lessThan(AmbienceService.peak));

      await drainFade(tester);
    });

    testWidgets('it leaves gently, and lets the player go', (tester) async {
      await startUnderFakeClock(tester, ambience);
      await tester.pump(SplashScreen.fade);
      ambience.land();
      await tester.pump(AmbienceService.hold);

      // Part way down: quieter, but not cut off.
      await tester.pump(AmbienceService.fadeOut ~/ 2);
      expect(ambience.volume, lessThan(AmbienceService.peak));
      expect(ambience.volume, greaterThan(0));

      await drainFade(tester);
      expect(ambience.volume, closeTo(0, 0.001));
      expect(player.stops, 1);
      expect(player.disposals, 1);
    });

    testWidgets('the whole shape fits inside the clip', (tester) async {
      // 18s of audio has to cover the splash from the handoff of the
      // wordmark, plus the hold, plus the fade out. If somebody retimes the
      // prompts, this is what says the file is now too short.
      final splashAfterStart =
          SplashScreen.breathHold * SplashScreen.prompts.length;
      final needed =
          splashAfterStart + AmbienceService.hold + AmbienceService.fadeOut;

      final bytes = await rootBundle.load(AmbienceService.asset);
      // 64 kbps mono: 8000 bytes a second.
      final seconds = bytes.lengthInBytes / 8000;
      expect(
        seconds,
        greaterThan(needed.inMilliseconds / 1000),
        reason: 'the clip is shorter than the sequence that plays over it',
      );
    });

    testWidgets('starting twice does not stack two players', (tester) async {
      await startUnderFakeClock(tester, ambience);
      await startUnderFakeClock(tester, ambience);
      expect(player.plays, 1);
      await tester.pump(SplashScreen.fade);
    });

    testWidgets('landing twice does not restart the fade', (tester) async {
      await startUnderFakeClock(tester, ambience);
      await tester.pump(SplashScreen.fade);
      ambience.land();
      await tester.pump(AmbienceService.hold);
      await drainFade(tester);
      expect(ambience.volume, closeTo(0, 0.001));

      ambience.land();
      await tester.pump(AmbienceService.hold);
      await drainFade(tester);
      expect(ambience.volume, closeTo(0, 0.001));
      expect(player.disposals, 1);
    });

    testWidgets('a missing or unplayable file is not an error', (tester) async {
      // A device with no audio, a codec that will not open, a file dropped
      // from the bundle. None of it is worth a message to somebody who
      // came here to calm down.
      player.failWith = Exception('no such asset');
      await startUnderFakeClock(tester, ambience);

      expect(player.plays, 0);
      expect(ambience.volume, 0);
      // And it can be asked again without throwing.
      ambience.land();
      await tester.pump(AmbienceService.hold);
      await drainFade(tester);
    });

    testWidgets('stop silences it at once', (tester) async {
      await startUnderFakeClock(tester, ambience);
      await tester.pump(SplashScreen.fade);
      unawaited(ambience.stop());
      await tester.pump();

      expect(player.disposals, 1);
      expect(ambience.isFading, isFalse);
    });

    test('a disabled service touches nothing', () async {
      final off = AmbienceService(player: player, enabled: false);
      await off.start();
      off.land();
      expect(player.plays, 0);
      expect(player.volumes, isEmpty);
    });
  });

  group('the splash', () {
    testWidgets('asks for the stream, and is not held up by it',
        (tester) async {
      // The one thing that must not happen: audio setup delaying the
      // prompts or the handoff. A player that never answers is the worst
      // case, so that is what this uses.
      Get.testMode = true;
      final stalled = _StalledService();
      Get.put<AmbienceService>(stalled, permanent: true);

      await PrefUtils().init();
      Get.put(await SessionService().init(), permanent: true);
      Get.put(await ThemeService().init(), permanent: true);
      Get.put(await LanguageService().init(), permanent: true);
      InitialBindings().dependencies();
      // Put back after InitialBindings, which does not know about it.
      Get.put<AmbienceService>(stalled, permanent: true);

      disableMotion(tester);
      await tester.pumpWidget(
        Sizer(
          builder: (_, _, _) => GetMaterialApp(
            theme: theme,
            getPages: AppPages.pages,
            initialRoute: AppRoutes.splash,
          ),
        ),
      );

      // Three seconds in, the wordmark leaves and the stream is asked for.
      await tester.pump(SplashScreen.brandHold + const Duration(seconds: 1));
      expect(stalled.starts, 1);

      // The prompts carry on regardless.
      for (var i = 0; i < SplashScreen.prompts.length; i++) {
        await tester.pump(SplashScreen.breathHold);
      }
      await tester.pumpAndSettle();

      expect(stalled.lands, 1, reason: 'the handoff never told the stream');
    });
  });
}

/// An ambience whose player never answers, to prove the splash does not wait.
class _StalledService extends AmbienceService {
  _StalledService() : super(enabled: false);

  int starts = 0;
  int lands = 0;

  @override
  Future<void> start() async {
    starts++;
    // Never completes.
    await Completer<void>().future;
  }

  @override
  void land() => lands++;
}
