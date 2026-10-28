import 'dart:io';

import 'package:flutter/material.dart';
import 'package:soothifyafrica/app/data/models/signed_in_user.dart';
import 'package:soothifyafrica/app/data/models/user_role.dart';
import 'package:soothifyafrica/app/data/repositories/auth_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flutter_map/flutter_map.dart';

import 'package:soothifyafrica/app/core/utils/map_tiles.dart';
import 'package:soothifyafrica/app/core/utils/where_i_am.dart';
import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';
import 'package:soothifyafrica/app/widgets/soothify_word.dart';


/// Stands in for [AuthRepository] in tests.
///
/// The real one drives Google's and Apple's SDKs and the Django API, neither
/// of which can run in a test — so what is exercised here is what the
/// controllers do with each answer: a session, a cancellation (null), or a
/// failure.
class StubAuthRepository implements AuthRepository {
  StubAuthRepository({
    this.role = UserRole.user,
    this.error,
    this.kycComplete = false,
    this.emailIsAvailable = true,
  });

  /// The role a successful sign-in returns. Null stands for the user
  /// dismissing the provider's own sheet.
  final UserRole? role;

  /// Whether the session says the questionnaire is done, which is what the
  /// controllers route on.
  final bool kycComplete;

  final bool emailIsAvailable;

  /// Thrown instead, when a test wants the failure path.
  final Object? error;

  int googleCalls = 0;
  int appleCalls = 0;
  int registerCalls = 0;
  int signInCalls = 0;
  int signOutCalls = 0;
  int resetRequests = 0;

  /// What was last sent, so a test can check the form reached the server.
  String? lastEmail;
  String? lastPassword;
  String? lastFullName;
  String? lastCode;

  SignedInUser? get _user => role == null
      ? null
      : SignedInUser(role: role!, kycComplete: kycComplete);

  @override
  Future<SignedInUser?> signInWithGoogle() async {
    googleCalls++;
    if (error != null) throw error!;
    return _user;
  }

  @override
  Future<SignedInUser?> signInWithApple() async {
    appleCalls++;
    if (error != null) throw error!;
    return _user;
  }

  @override
  Future<SignedInUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    registerCalls++;
    lastFullName = fullName;
    lastEmail = email;
    lastPassword = password;
    if (error != null) throw error!;
    return _user ?? const SignedInUser(role: UserRole.user);
  }

  @override
  Future<SignedInUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    lastEmail = email;
    lastPassword = password;
    if (error != null) throw error!;
    return _user ?? const SignedInUser(role: UserRole.user);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (error != null) throw error!;
  }

  int deleteCalls = 0;

  @override
  Future<void> deleteAccount(String confirm) async {
    deleteCalls++;
    lastPassword = confirm;
    if (error != null) throw error!;
  }

  @override
  Future<bool> emailAvailable(String email) async {
    lastEmail = email;
    if (error != null) throw error!;
    return emailIsAvailable;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    resetRequests++;
    lastEmail = email;
    if (error != null) throw error!;
  }

  @override
  Future<SignedInUser> confirmPasswordReset({
    required String email,
    required String code,
    required String password,
  }) async {
    lastEmail = email;
    lastCode = code;
    lastPassword = password;
    if (error != null) throw error!;
    return _user ?? const SignedInUser(role: UserRole.user);
  }
}

/// Every cover a library screen can draw.
///
/// Shared rather than copied per test file. It was duplicated, one copy
/// drifted to a subset, and the screens behind it rendered their article
/// titles two pixels off — because an asset that is not precached resolves
/// late and the layout settles after the golden is taken.
const libraryCovers = <String>[
  'assets/images/explore/pilates_core.png',
  'assets/images/explore/stretch_restore.png',
  'assets/images/library/balance_session.png',
  'assets/images/library/meditation_session.png',
  'assets/images/library/sleep_stories.png',
  'assets/images/content/cover_d.png',
  'assets/images/content/yoga_vinyasa.png',
  'assets/images/content/yoga_hatha.png',
  'assets/images/content/yoga_restorative.png',
  'assets/images/content/rest_sleep.png',
  'assets/images/content/rest_ambient.png',
  'assets/images/content/cover_a.png',
  'assets/images/content/cover_b.png',
  'assets/images/content/cover_c.png',
  'assets/images/content/unshakeable.png',
  'assets/images/content/hope_in_the_shadows.png',
  'assets/images/content/breaking_bad_habit.png',
  'assets/images/content/daily_focus.png',
  'assets/images/content/breath_work.png',
  'assets/images/content/mindfulness.png',
];


/// Loads every bundled face. Without this, golden renders fall back to the
/// test font and every glyph becomes a box.
///
/// Must list all families declared in pubspec.yaml — a missing entry shows up
/// only as boxes in a golden, which is easy to miss.
Future<void> loadAppFonts() async {
  const faces = {
    'Nunito': 'assets/fonts/Nunito-Variable.ttf',
    'NunitoSans': 'assets/fonts/NunitoSans-Variable.ttf',
    'Pacifico': 'assets/fonts/Pacifico-Regular.ttf',
  };
  for (final e in faces.entries) {
    final loader = FontLoader(e.key)..addFont(rootBundle.load(e.value));
    await loader.load();
  }
  await _loadMaterialIcons();
}

/// Material icons are not bundled into the test asset bundle, so any [Icon]
/// renders as an empty box in a golden. The font ships inside the Flutter SDK;
/// load it from there when it can be found, and carry on without it when it
/// cannot, so this never breaks a run on another machine.
Future<void> _loadMaterialIcons() async {
  final root = Platform.environment['FLUTTER_ROOT'] ??
      _flutterRootFromExecutable();
  if (root == null) return;

  final file = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!file.existsSync()) return;

  final bytes = ByteData.sublistView(file.readAsBytesSync());
  await (FontLoader('MaterialIcons')..addFont(Future.value(bytes))).load();
}

String? _flutterRootFromExecutable() {
  // dart is at <root>/bin/cache/dart-sdk/bin/dart
  final parts = Platform.resolvedExecutable.split('/bin/cache/');
  return parts.length > 1 ? parts.first : null;
}

/// Pins the test surface to the Figma frame (390x844) so `.h` and `.v`
/// resolve 1:1, as on the reference device.
void useDesignFrame(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(figmaDesignWidth * 3, figmaDesignHeight * 3)
    ..devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });
}

/// Mounts [child] the way `main.dart` does — inside a [Sizer], with both
/// themes registered — so screens resolve fonts, sizing and palette exactly as
/// they will at runtime.
/// Set [motion] to true only for a test that is checking an animation. The
/// default switches motion off, because [pumpScreen] ends in `pumpAndSettle`
/// and anything that repeats forever — a skeleton's shimmer, the assist
/// button's drift — never gives it a still frame to stop on.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  bool motion = false,
  List<GetPage<dynamic>>? pages,
}) async {
  if (!motion) disableMotion(tester);
  await tester.pumpWidget(
    Sizer(
      builder: (_, _, _) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        themeMode:
            brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, widget) {
          PrimaryColors.syncFrom(context);
          return widget!;
        },
        // Only for screens whose buttons leave: without the route named on
        // the way out, GetX throws rather than navigating.
        getPages: pages,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Lets a repository's latency elapse.
///
/// [pumpScreen] settles animations, but `pumpAndSettle` only advances the
/// clock while a frame is scheduled, and a pending `Future.delayed` schedules
/// none. A screen that loads its content from a repository therefore stays
/// empty until the clock is moved on by hand -- which is what this does.
Future<void> settleLoads(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

/// Asset images resolve asynchronously; without precaching they render blank
/// in a golden.
Future<void> precacheAll(
  WidgetTester tester,
  Finder scope,
  Iterable<String> assetPaths,
) async {
  await tester.runAsync(() async {
    final element = tester.element(scope);
    for (final path in assetPaths) {
      await precacheImage(AssetImage(path), element);
    }
  });
  await tester.pumpAndSettle();
}

/// A pinned clock for goldens.
///
/// Home greets by time of day, so a golden recorded in the morning fails that
/// evening — which is exactly what happened. [HomeTabController] already takes
/// an injectable clock for this; the golden tests just never passed one.
/// Pinned to a morning hour because the frame prints "Good morning".
DateTime fixedMorning() => DateTime(2026, 1, 1, 9);

/// Turns off "reduce motion"-aware animations for a test.
///
/// Some screens carry a perpetual animation — the Home assist button drifts
/// forever — and nothing waiting on a still frame can settle while one runs.
/// Tests that need pumpAndSettle, or a deterministic golden, switch it off.
void disableMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

/// Finds text that may carry the brand's smile under its "oo".
///
/// [SoothifyText] splits "Soothify" into a `WidgetSpan`, so `find.text` no
/// longer sees the whole string. Matching the widget by the string it was
/// given finds it either way, and needs no semantics handle — which
/// `find.bySemanticsLabel` would, since a widget test builds no semantics
/// tree unless one is open.
Finder findSoothify(String text) => find.byWidgetPredicate(
      (w) =>
          (w is SoothifyText && w.data == text) ||
          (w is Text && w.data == text),
      description: 'text "$text"',
    );


/// A tile provider that serves one flat colour and asks the network for
/// nothing.
///
/// The map would otherwise make a real request per tile: a widget test has
/// no network, so every one fails and buries the actual result, and a
/// golden drawn over live tiles would change with whatever OpenStreetMap
/// served that minute.
class StubTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(Uint8List.fromList(_onePixel));

  /// A 1x1 opaque PNG, stretched over each tile.
  static const _onePixel = <int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
    0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
    0x00, 0x03, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xB0, 0x00, 0x00, 0x00,
    0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ];
}

/// Points the map at [StubTileProvider] for the rest of the test file, and
/// answers the location question without a platform to ask.
///
/// Both matter on the Spaces screen: the tiles would otherwise be fetched
/// over a network the test does not have, and the permission check would
/// hang on a channel nobody is listening to -- which held the list back
/// and left it empty.
void useStubTiles() {
  MapTiles.provider = StubTileProvider.new;
  WhereIAm.allowedCheck = () async => false;
  WhereIAm.finder = () async => null;
}
