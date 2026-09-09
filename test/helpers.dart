import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/core/utils/size_utils.dart';
import 'package:soothifyafrica/app/theme/theme_helper.dart';

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
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
}) async {
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
        home: child,
      ),
    ),
  );
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
