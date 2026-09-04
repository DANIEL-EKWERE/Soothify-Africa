import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The golden helper loads fonts by hand. If a family is added to pubspec.yaml
/// and not to the helper, goldens silently render that text as boxes — so
/// assert the two stay in step.
void main() {
  test('every pubspec font family is loaded by the golden helper', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final declared = RegExp(r'^\s*- family:\s*(\S+)\s*$', multiLine: true)
        .allMatches(pubspec)
        .map((m) => m.group(1)!)
        .toSet();

    final helper = File('test/helpers.dart').readAsStringSync();
    final loaded = RegExp(r"'([A-Za-z]+)':\s*'assets/fonts/")
        .allMatches(helper)
        .map((m) => m.group(1)!)
        .toSet();

    expect(declared, isNotEmpty, reason: 'no font families found in pubspec');
    expect(
      declared.difference(loaded),
      isEmpty,
      reason: 'add these families to loadAppFonts() in test/helpers.dart',
    );
  });
}
