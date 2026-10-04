import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/journal_entry.dart';
import 'package:soothifyafrica/app/data/repositories/journal_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_journal_repository.dart';
import 'package:soothifyafrica/app/modules/user/journal/controller/journal_controller.dart';
import 'package:soothifyafrica/app/modules/user/journal/journal_screen.dart';
import 'package:soothifyafrica/app/modules/user/journal/widgets/expert_recommendation_view.dart';
import 'package:soothifyafrica/app/modules/user/journal/widgets/session_card.dart';

import 'helpers.dart';

/// Regenerate with:
///   flutter test --update-goldens test/journal_golden_test.dart
const _art = [
  'assets/images/journal/empty.png',
  'assets/images/notifications/avatar_female.png',
  'assets/images/journal/expert_avatar.png',
  'assets/images/content/breath_work.png',
  'assets/images/content/mindfulness.png',
  'assets/images/content/daily_focus.png',
];

void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  /// Pinned: cards print the day a note was written, and the expert card its
  /// own date, so a golden off the real clock goes stale overnight.
  DateTime now() => DateTime(2026, 9, 28, 9, 41);

  Future<JournalController> mount(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    int entries = 0,
  }) async {
    useDesignFrame(tester);
    await loadAppFonts();
    final repo = LocalJournalRepository(now: now);
    for (var i = 0; i < entries; i++) {
      await repo.save(
        body: 'Feeling more present today\nThere are no limits on topics in '
            'your Notepad. Write down how feel, what you’re planning, or '
            'simply something you noticed.',
      );
    }
    Get.put<JournalRepository>(repo);
    final c = Get.put(JournalController(repo, now: now));
    await pumpScreen(tester, const JournalScreen(), brightness: brightness);
    await tester.pumpAndSettle();
    return c;
  }

  for (final (name, brightness) in [
    ('light', Brightness.light),
    ('dark', Brightness.dark),
  ]) {
    testWidgets('journal empty state, $name', (tester) async {
      await mount(tester, brightness: brightness);
      await precacheAll(tester, find.byType(JournalScreen), _art);

      await expectLater(find.byType(JournalScreen),
          matchesGoldenFile('goldens/journal_$name.png'));
    });

    testWidgets('journal entries, $name', (tester) async {
      await mount(tester, brightness: brightness, entries: 4);
      await precacheAll(tester, find.byType(JournalScreen), _art);

      await expectLater(find.byType(JournalScreen),
          matchesGoldenFile('goldens/journal_entries_$name.png'));
    });

    testWidgets('expert recommendation tab, $name', (tester) async {
      final c = await mount(tester, brightness: brightness);
      c.select(JournalTab.expert);
      await tester.pumpAndSettle();
      await precacheAll(tester, find.byType(JournalScreen), _art);

      await expectLater(find.byType(JournalScreen),
          matchesGoldenFile('goldens/journal_expert_$name.png'));
    });
  }

  // The app bar is also titled "Journal", so the tab halves are addressed
  // through their own container rather than by text alone.
  Finder half(String label) => find.descendant(
        of: find.byType(AnimatedContainer),
        matching: find.text(label),
      );

  testWidgets('both halves of the tab are reachable', (tester) async {
    final c = await mount(tester);
    expect(c.tab.value, JournalTab.own);

    await tester.tap(half('Expert Recommendation'));
    await tester.pumpAndSettle();
    expect(c.tab.value, JournalTab.expert);
    expect(find.byType(ExpertRecommendationView), findsOneWidget);
    // Grouped as the frame groups them, with one session in each group.
    expect(find.text('Recent Live Sessions'), findsOneWidget);
    expect(find.text('Earlier Sessions'), findsOneWidget);
    expect(find.byType(SessionCard), findsNWidgets(3));
    // Nothing to compose on the expert's side, so the button goes away.
    expect(find.byIcon(Icons.add), findsNothing);

    await tester.tap(half('Journal'));
    await tester.pumpAndSettle();
    expect(c.tab.value, JournalTab.own);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('the empty state gives way to cards once a note exists',
      (tester) async {
    await mount(tester, entries: 2);
    expect(find.text('No entries yet'), findsNothing);
    expect(find.text('Sep 28, 2026'), findsNWidgets(2));
  });

  testWidgets('each session names its own action', (tester) async {
    final c = await mount(tester);
    c.select(JournalTab.expert);
    await tester.pumpAndSettle();
    // The frame's three cards carry three different actions; a shared label
    // would lose that.
    expect(find.text('Watch video'), findsOneWidget);
    expect(find.text('Read Article'), findsOneWidget);
    expect(find.text('Listen'), findsOneWidget);
    expect(c.unread, 1);
    expect(find.text('New'), findsOneWidget);
  });

  test('the chosen half of the tab grows, and the pair still fills 342', () {
    for (final chosen in JournalTab.values) {
      final total = JournalTab.values
          .map((t) => t.widthWhen(selected: t == chosen))
          .reduce((a, b) => a + b);
      expect(total, 342, reason: 'the control is 342 wide in both frames');
    }
    // `259:36965` draws Journal chosen at 152 and `259:60761` draws Expert
    // chosen at 211, with the unread badge hanging off the control's right
    // end. The badge now sits inside the pill beside the label it counts, so
    // the Expert half carries both and the split moved with it.
    expect(JournalTab.own.widthWhen(selected: true), 110);
    expect(JournalTab.expert.widthWhen(selected: true), 253);
    // Whichever is chosen, Expert keeps enough for "Expert Recommendation"
    // at 14 plus the badge — about 184 of it.
    for (final chosen in JournalTab.values) {
      expect(
        JournalTab.expert.widthWhen(selected: chosen == JournalTab.expert),
        greaterThanOrEqualTo(200),
      );
    }
  });

  group('JournalEntry.titleFrom', () {
    test('takes the note’s opening line, which is what a card heads with', () {
      expect(
        JournalEntry.titleFrom('Feeling more present today\nrest of it'),
        'Feeling more present today',
      );
    });

    test('skips leading blank lines rather than titling a card ""', () {
      expect(JournalEntry.titleFrom('\n\n  Slept badly  \nmore'),
          'Slept badly');
    });

    test('cuts a long opening on a word boundary', () {
      final title = JournalEntry.titleFrom('${'a' * 10} ${'b' * 80}');
      expect(title.length, lessThanOrEqualTo(49));
      expect(title, endsWith('…'));
    });

    test('an empty note has no title rather than throwing', () {
      expect(JournalEntry.titleFrom('   '), '');
    });
  });

  test('saving persists, and clearing a note removes it', () async {
    final repo = LocalJournalRepository(now: now);
    final saved = await repo.save(body: 'First note\nbody');
    expect(await repo.entries(), hasLength(1));
    expect((await repo.getById(saved.id))?.title, 'First note');

    // Editing keeps the day it was written, so the list does not reshuffle.
    final edited = await repo.save(body: 'Renamed\nbody', id: saved.id);
    expect(edited.createdAt, saved.createdAt);
    expect(await repo.entries(), hasLength(1));

    await repo.delete(saved.id);
    expect(await repo.entries(), isEmpty);
  });
}
