import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soothifyafrica/app/widgets/soothify_word.dart';

import 'helpers.dart';

void main() {
  test('no screen prints the brand name in a plain Text', () {
    // The name carries a smile under its two o's wherever it is shown, which
    // SoothifyText draws and a plain Text does not. A new call site is easy
    // to add and impossible to spot by eye across forty screens, so this
    // reads the source instead.
    //
    // Each `Text(` is matched to its own closing bracket, so a literal that
    // merely sits near one — an argument to some other widget further down —
    // is not mistaken for its content.
    final offenders = <String>[];
    final call = RegExp(r'(?<![A-Za-z])Text\(');

    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (file.path.endsWith('soothify_word.dart')) continue;
      final source = file.readAsStringSync();
      for (final match in call.allMatches(source)) {
        var depth = 0;
        var i = match.end - 1;
        for (; i < source.length; i++) {
          if (source[i] == '(') depth++;
          if (source[i] == ')') {
            depth--;
            if (depth == 0) break;
          }
        }
        final args = source.substring(match.end, i < source.length ? i : null);
        if (!args.contains('Soothify')) continue;
        final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;
        offenders.add('${file.path}:$line');
      }
    }

    expect(offenders, isEmpty,
        reason: 'use SoothifyText for these:\n${offenders.join('\n')}');
  });

  testWidgets('the mark is drawn, and the plain name is still readable',
      (tester) async {
    await loadAppFonts();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: SoothifyText('Welcome to Soothify')),
        ),
      ),
    );

    // The word is split into its own span, so the string is no longer one
    // Text — but it is still what assistive tech is handed.
    expect(find.text('Welcome to Soothify'), findsNothing);
    expect(findSoothify('Welcome to Soothify'), findsOneWidget);
    expect(find.byType(SoothifyWord), findsOneWidget);

    // A string without the name is left as an ordinary Text.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: SoothifyText('Welcome back'))),
      ),
    );
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(SoothifyWord), findsNothing);
  });
}
