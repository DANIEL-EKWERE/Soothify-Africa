import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:soothifyafrica/app/data/models/booked_session.dart';
import 'package:soothifyafrica/app/data/models/coach.dart';
import 'package:soothifyafrica/app/data/models/session_offering.dart';
import 'package:soothifyafrica/app/data/repositories/booking_repository.dart';
import 'package:soothifyafrica/app/data/repositories/kyc_repository.dart';
import 'package:soothifyafrica/app/modules/user/booking/controller/booking_controller.dart';

/// Who the matching screen lands on.
///
/// It printed [Coach.sample] — one hardcoded name, one hardcoded blurb,
/// "98% Match" — to everybody, whatever the server had matched them with.

class _Bookings implements BookingRepository {
  _Bookings(this._found);

  final MatchedExpert? _found;
  int calls = 0;
  String? askedFor;

  @override
  Future<MatchedExpert?> match({
    required String discipline,
    DateTime? day,
    int? startMinute,
    String? language,
  }) async {
    calls += 1;
    askedFor = discipline;
    return _found;
  }

  @override
  Future<List<FreeSlot>> freeSlots(String expertId,
          {DateTime? from, DateTime? to}) async =>
      const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Kyc implements KycRepository {
  _Kyc(this._answers);

  final Map<String, Set<String>> _answers;

  @override
  Future<Map<String, Set<String>>> savedAnswers() async => _answers;

  @override
  Future<void> saveAnswers(Map<String, Set<String>> answers) async {}

  @override
  Future<bool> isComplete() async => true;

  @override
  Future<void> markComplete() async {}
}

const _expert = MatchedExpert(
  id: '3',
  name: 'Baraqhat Ibrahim',
  headline: 'Yoga and breath',
  bio: 'Fifteen years of hatha and restorative practice in Lagos.',
  quote: '“Live your life in your truth.”',
  disciplines: ['yoga', 'therapy'],
  interests: ['Pop music lover', 'Enjoys being active'],
  rating: 4.8,
  avatarUrl: 'https://example.test/coach.jpg',
  matchPercent: 92,
);

void main() {
  tearDown(Get.reset);

  BookingController build({
    MatchedExpert? found = _expert,
    Map<String, Set<String>> answers = const {},
    SessionOffering? offering,
    bool wired = true,
  }) {
    final bookings = _Bookings(found);
    return BookingController(
      offering: offering,
      matchDuration: const Duration(milliseconds: 10),
      bookings: wired ? bookings : null,
      kyc: wired ? _Kyc(answers) : null,
    );
  }

  group('the coach the screen lands on', () {
    test('is the one the server matched, not the frame sample', () async {
      final c = build()..onInit();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(c.matched.value?.name, 'Baraqhat Ibrahim');
      expect(c.coach.name, 'Baraqhat Ibrahim');
      expect(c.coach.matchPercent, 92);
      expect(c.coach.quote, '“Live your life in your truth.”');
      expect(c.coach.blurb, contains('hatha'));
      // "Outside of Soothify" is what they are into.
      expect(c.coach.outside, ['Pop music lover', 'Enjoys being active']);
      // 'yoga' is stored; 'Yoga' is printed.
      expect(c.coach.expertise, ['Yoga', 'Therapy']);
      expect(c.coach.avatarUrl, 'https://example.test/coach.jpg');
    });

    test('it asks for the discipline that was booked', () async {
      final bookings = _Bookings(_expert);
      final c = BookingController(
        offering: SessionOffering.balance,
        matchDuration: const Duration(milliseconds: 10),
        bookings: bookings,
      )..onInit();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(bookings.askedFor, SessionOffering.balance.id);
    });

    test('nobody free is said, not papered over with a sample', () async {
      final c = build(found: null)..onInit();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(c.nobodyAvailable.value, isTrue);
      expect(c.matched.value, isNull);
    });

    test('with no repository it still shows the frame coach', () {
      // The build with no backend, and every golden of this screen.
      final c = build(wired: false);

      expect(c.coach.name, Coach.sample.name);
    });
  });

  group('"Because you feel..."', () {
    test('comes from the questionnaire, not from the expert', () async {
      final c = build(answers: {
        'concerns': {'stress', 'sleep_disorder'},
        // Not a feeling, and not drawn on this screen.
        'gender': {'female'},
      })..onInit();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(c.coach.feelings, ['Stressed', 'Restless']);
    });

    test('an unanswered questionnaire draws no chips', () async {
      final c = build()..onInit();
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(c.coach.feelings, isEmpty);
    });
  });
}
