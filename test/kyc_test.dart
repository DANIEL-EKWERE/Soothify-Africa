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
        ['concerns', 'frequency', 'in_treatment', 'goals', 'gender', 'age'],
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

    test('Next stays blocked until the question is answered', () {
      expect(controller.canProceed, isFalse);
      controller.choose(optionOf('concerns', 'stress'));
      expect(controller.canProceed, isTrue);
    });

    test('multi-select accumulates, and toggles off', () {
      controller
        ..choose(optionOf('concerns', 'stress'))
        ..choose(optionOf('concerns', 'anxiety'));
      expect(controller.current, {'stress', 'anxiety'});

      controller.choose(optionOf('concerns', 'stress'));
      expect(controller.current, {'anxiety'});
    });

    test('single-select replaces rather than accumulating', () async {
      controller.choose(optionOf('concerns', 'stress'));
      await controller.next();

      controller
        ..choose(optionOf('frequency', 'regularly'))
        ..choose(optionOf('frequency', 'not_at_all'));

      expect(controller.current, {'not_at_all'});
    });

    test('advances through the questions and can step back', () async {
      expect(controller.question.id, 'concerns');

      controller.choose(optionOf('concerns', 'stress'));
      await controller.next();
      expect(controller.question.id, 'frequency');

      controller.back();
      expect(controller.question.id, 'concerns');
      // Going back must not discard the answer.
      expect(controller.current, {'stress'});
    });

    test('back does nothing on the first question', () {
      controller.back();
      expect(controller.step.value, 0);
    });

    test('saves progress as it goes, not only at the end', () async {
      controller.choose(optionOf('concerns', 'stress'));
      await controller.next();

      expect(await repo.savedAnswers(), {
        'concerns': {'stress'},
      });
      // Partway through is not "complete".
      expect(await repo.isComplete(), isFalse);
    });

    test('resumes at the first unanswered question', () async {
      await repo.saveAnswers({
        'concerns': {'stress'},
        'frequency': {'regularly'},
      });

      final resumed = KycController(repo)..onInit();
      await Future<void>.delayed(Duration.zero);

      expect(resumed.question.id, 'in_treatment');
      expect(resumed.answers['concerns'], {'stress'});
    });
  });
}
