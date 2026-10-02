import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/data/models/kyc_question.dart';
import 'package:soothifyafrica/app/data/repositories/local_kyc_repository.dart';
import 'package:soothifyafrica/app/modules/auth/kyc/controller/kyc_controller.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  KycOption optionOf(String questionId, String value) => KycQuestion.all
      .firstWhere((q) => q.id == questionId)
      .options
      .firstWhere((o) => o.value == value);

  group('KycQuestion', () {
    test('carries the six designed questions in order', () {
      expect(
        KycQuestion.all.map((q) => q.id),
        // Gender leads: the concerns carousel draws a gendered figure, so
        // the answer has to exist by the time that step is reached.
        ['gender', 'concerns', 'frequency', 'in_treatment', 'goals',
          'birth_year'],
      );
    });

    test('only the two designed questions are multi-select', () {
      expect(
        KycQuestion.all.where((q) => q.isMulti).map((q) => q.id),
        ['concerns', 'goals'],
      );
    });

    test('the age step now collects a birth year — Figma 259:27860', () {
      // Was a wheel of ages 18-50 under "How old are you?".
      final q = KycQuestion.allFor(2026).last;
      expect(q.id, 'birth_year');
      expect(q.prompt, 'What is your age?');
      expect(q.input, KycInput.birthYear);

      // Newest year first, as the frame lists them. The top of the wheel is
      // the youngest year *offered*, not the youngest accepted — see the age
      // gate group below.
      expect(q.options.first.label, '2013'); // 2026 - 13
      expect(q.options.last.label, '1976'); // 2026 - 50
      expect(q.options, hasLength(38));
    });

    test('the wheel moves with the calendar', () {
      expect(KycQuestion.allFor(2027).last.options.first.label, '2014');
    });

    test('the readout is the age the year implies', () {
      expect(KycQuestion.ageFor('1993', 2026), 33);
      expect(KycQuestion.ageFor('2008', 2026), 18);
      // The frame prints "20" beside a boxed 1993; that is a placeholder, and
      // this is what the app shows instead.
      expect(KycQuestion.ageFor('1993', 2026), isNot(20));
    });
  });

  group('the age gate', () {
    test('the wheel scrolls past 18 so the rule can be shown', () {
      final q = KycQuestion.allFor(2026).last;
      // Youngest offered is 13, not 18: a list that simply stops at the limit
      // gives someone younger nothing to scroll to and no reason why.
      expect(q.options.first.label, '2013');
      expect(KycQuestion.ageFor('2013', 2026), 13);
      expect(q.options.last.label, '1976');
    });

    test('years under 18 are refused, 18 and over are not', () {
      expect(KycQuestion.isUnderage('2009', 2026), isTrue); // 17
      expect(KycQuestion.isUnderage('2008', 2026), isFalse); // 18
      expect(KycQuestion.isUnderage('1990', 2026), isFalse);
      expect(KycQuestion.underageMessage, contains('18 or older'));
    });
  });

  group('LocalKycRepository', () {
    test('round-trips answers keyed by question', () async {
      final repo = LocalKycRepository();
      await repo.saveAnswers({
        'concerns': {'stress', 'anxiety'},
        'gender': {'female'},
      });

      expect(await repo.savedAnswers(), {
        'concerns': {'stress', 'anxiety'},
        'gender': {'female'},
      });
    });

    test('starts empty and incomplete', () async {
      final repo = LocalKycRepository();
      expect(await repo.savedAnswers(), isEmpty);
      expect(await repo.isComplete(), isFalse);
    });

    test('survives corrupt stored data by reporting it', () async {
      SharedPreferences.setMockInitialValues({'kycAnswers': 'not json'});
      expect(LocalKycRepository().savedAnswers(), throwsA(isA<Exception>()));
    });
  });

  group('KycController', () {
    late LocalKycRepository repo;
    late KycController controller;

    setUp(() {
      repo = LocalKycRepository();
      controller = KycController(repo);
    });

    /// Gender is the opening question; the concerns carousel is second.
    Future<void> pastGender() async {
      controller.choose(optionOf('gender', 'female'));
      await controller.next();
    }

    test('Next stays blocked until the question is answered', () {
      expect(controller.canProceed, isFalse);
      controller.choose(optionOf('gender', 'female'));
      expect(controller.canProceed, isTrue);
    });

    test('multi-select accumulates, and toggles off', () async {
      await pastGender();
      controller
        ..choose(optionOf('concerns', 'stress'))
        ..choose(optionOf('concerns', 'anxiety'));
      expect(controller.current, {'stress', 'anxiety'});

      controller.choose(optionOf('concerns', 'stress'));
      expect(controller.current, {'anxiety'});
    });

    test('single-select replaces rather than accumulating', () {
      controller
        ..choose(optionOf('gender', 'male'))
        ..choose(optionOf('gender', 'female'));

      expect(controller.current, {'female'});
    });

    test('advances through the questions and can step back', () async {
      expect(controller.question.id, 'gender');

      await pastGender();
      expect(controller.question.id, 'concerns');

      controller.back();
      expect(controller.question.id, 'gender');
      // Going back must not discard the answer.
      expect(controller.current, {'female'});
    });

    test('back does nothing on the first question', () {
      controller.back();
      expect(controller.step.value, 0);
    });

    test('saves progress as it goes, not only at the end', () async {
      await pastGender();

      expect(await repo.savedAnswers(), {
        'gender': {'female'},
      });
      // Partway through is not "complete".
      expect(await repo.isComplete(), isFalse);
    });

    test('resumes at the first unanswered question', () async {
      await repo.saveAnswers({
        'gender': {'female'},
        'concerns': {'stress'},
      });

      final resumed = KycController(repo)..onInit();
      await Future<void>.delayed(Duration.zero);

      expect(resumed.question.id, 'frequency');
      expect(resumed.answers['concerns'], {'stress'});
    });
  });

  test('the concerns carousel resolves its art from the gender answer', () {
    final stress = KycQuestion.all
        .firstWhere((q) => q.id == 'concerns')
        .options
        .firstWhere((o) => o.value == 'stress');

    // Only an explicit "male" switches sets; everything else, including no
    // answer at all, draws the female figure — matching the Mood Checker.
    expect(stress.illustrationFor('female'), stress.illustration);
    expect(stress.illustrationFor('non_binary'), stress.illustration);
    expect(stress.illustrationFor(null), stress.illustration);
    // "male" alone switches to the second set.
    expect(stress.illustrationMale, isNotNull);
    expect(stress.illustrationFor('male'), stress.illustrationMale);
    expect(stress.illustrationFor('male'), isNot(stress.illustration));
    // Every option has both figures, so no gender ever sees a mix.
    for (final o in KycQuestion.all.firstWhere((q) => q.id == 'concerns').options) {
      expect(o.illustration, isNotNull, reason: '${o.label} lacks female art');
      expect(o.illustrationMale, isNotNull, reason: '${o.label} lacks male art');
    }
  });
}
