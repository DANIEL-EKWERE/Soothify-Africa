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
        ['gender', 'concerns', 'frequency', 'in_treatment', 'goals', 'age'],
      );
    });

    test('only the two designed questions are multi-select', () {
      expect(
        KycQuestion.all.where((q) => q.isMulti).map((q) => q.id),
        ['concerns', 'goals'],
      );
    });

    test('the age question spans 18 to 50', () {
      final age = KycQuestion.all.last;
      expect(age.input, KycInput.wheel);
      expect(age.options.first.label, '18');
      expect(age.options.last.label, '50');
      expect(age.options, hasLength(33));
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
