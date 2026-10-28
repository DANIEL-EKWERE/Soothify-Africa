@Tags(['live'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/network/api_client.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/expert_application.dart';
import 'package:soothifyafrica/app/data/repositories/api_billing_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_expert_application_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_expert_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_booking_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_corporate_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_notification_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_profile_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_spaces_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_subscription_repository.dart';
import 'package:soothifyafrica/app/data/models/plan_tier.dart';

/// The app's repositories against a **real** Django server.
///
/// Everything else in this suite mocks the network, which proves the app
/// sends what it means to. This proves the other half: that the server
/// answers with what the app expects. The two are different failures, and
/// only this one catches a field renamed on the backend.
///
/// Not part of the normal run -- it needs a server:
///
///   cd soothifyAfrica && venv/bin/python manage.py runserver 127.0.0.1:8000
///   flutter test test/live_api_test.dart --run-skipped
///
/// Skips itself, loudly, when nothing is listening.
void main() {
  const base = String.fromEnvironment(
    'SOOTHIFY_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  late ApiClient api;
  var serverIsUp = false;

  setUpAll(() async {
    // flutter_test replaces HttpClient with one that answers 400 to
    // everything, so that a widget test cannot accidentally reach the
    // network. This file is the one place that is meant to.
    HttpOverrides.global = null;

    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    await PrefUtils().init();

    api = ApiClient(
      baseUrl: base,
      accessToken: () => PrefUtils().accessToken,
      refreshToken: () => PrefUtils().refreshToken,
      onTokens: (access, refresh) =>
          PrefUtils().setTokens(access: access, refresh: refresh),
    );

    try {
      final health = await api.get('/health/');
      serverIsUp = health['status'] == 'ok';
    } catch (_) {
      serverIsUp = false;
    }
    if (!serverIsUp) {
      // ignore: avoid_print
      print('No API at $base — skipping the live tests.');
    }
  });

  /// A fresh account per run, so a rerun is not a duplicate-email failure.
  Future<void> signIn() async {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final body = await api.post('/auth/register/', body: {
      'full_name': 'Live Tester',
      'email': 'live.$stamp@example.com',
      'password': 'Soothify2026',
    });
    final tokens = body['tokens'] as Map<String, dynamic>;
    await PrefUtils().setTokens(
      access: '${tokens['access']}',
      refresh: '${tokens['refresh']}',
    );
  }

  group('against a live server', () {
    setUp(() async {
      if (!serverIsUp) return;
      await signIn();
    });

    test('the library answers in the shape the app parses', () async {
      if (!serverIsUp) return;
      final content = ApiContentRepository(api);

      final categories = await content.getCategories();
      final featured = await content.getFeatured();

      expect(categories, isNotEmpty, reason: 'seed_content was not run');
      expect(featured, isNotEmpty);
      // The fields a card actually draws, rather than "it returned a list".
      final card = featured.first;
      expect(card.id, isNotEmpty);
      expect(card.title, isNotEmpty);
      expect(card.durationSeconds, greaterThanOrEqualTo(0));
    });

    test('a shelf comes back with its own items', () async {
      if (!serverIsUp) return;

      final row = await ApiContentRepository(api).getShelf('sounds');

      expect(row, isNotEmpty);
    });

    test('search finds by title and an empty search asks nothing', () async {
      if (!serverIsUp) return;
      final content = ApiContentRepository(api);

      final hits = await content.search('breath');

      expect(hits.map((i) => i.title).join(' ').toLowerCase(), contains('breath'));
      expect(await content.search('   '), isEmpty);
    });

    test('paid content hands out no playable link without a membership', () async {
      if (!serverIsUp) return;

      final items = await ApiContentRepository(api)
          .search('Morning flow');   // seeded as members-only

      if (items.isEmpty) return;     // not seeded; nothing to assert
      expect(items.first.remoteUrl, isEmpty);
    });

    test('the questionnaire saves, merges and completes', () async {
      if (!serverIsUp) return;
      final kyc = ApiKycRepository(api);

      await kyc.saveAnswers({'gender': {'female'}});
      await kyc.saveAnswers({'brings_you': {'stress', 'sleep'}});
      final saved = await kyc.savedAnswers();

      // Merged, not replaced: the screen saves after every question.
      expect(saved['gender'], {'female'});
      expect(saved['brings_you'], {'stress', 'sleep'});
      expect(await kyc.isComplete(), isFalse);

      await kyc.markComplete();
      expect(await kyc.isComplete(), isTrue);
    });

    test('a new account reads zero on the stats card', () async {
      if (!serverIsUp) return;

      final stats = await ApiProfileRepository(api).getStats();

      expect(stats.pilatesMinutes, 0);
      expect(stats.liveSessions, 0);
    });

    test('the plans screen has cards to show', () async {
      if (!serverIsUp) return;

      final tiers =
          await ApiSubscriptionRepository(api).getTiers(BillingPeriod.annual);

      expect(tiers, isNotEmpty, reason: 'seed_content was not run');
      expect(tiers.map((t) => t.name), contains('Soothify Core'));
    });

    test('a new account has no membership', () async {
      if (!serverIsUp) return;

      final membership = await ApiBillingRepository(api).membership();

      expect(membership.state, 'inactive');
      expect(membership.isActive, isFalse);
    });

    test('the free week asks for a card, and says what it costs', () async {
      if (!serverIsUp) return;
      final billing = ApiBillingRepository(api);

      final offer = await billing.membership();
      final checkout = await billing.startMembership(planKey: 'core-annual');

      if (!offer.trialRequiresCard) {
        // Configured to give the week away: it starts here, with nothing to
        // open and nothing to pay.
        expect(checkout.trialStarted, isTrue);
        expect(checkout.checkoutUrl, isEmpty);
        expect((await billing.membership()).state, 'trial');
        return;
      }

      // A card is asked for, so what opens is the check -- not the price of
      // the plan, and not the week itself.
      expect(offer.cardCheckNaira, greaterThan(0));
      expect(checkout.cardCheckNaira, offer.cardCheckNaira);
      expect(checkout.checkoutUrl, isNotEmpty);
      expect(checkout.trialStarted, isFalse);
      // Nothing is being bought: the check goes back.
      expect(checkout.dueTodayNaira, 0);

      // And nothing is granted by asking. The week begins when the card
      // reaches the server, which only a real checkout can do -- so that
      // half is covered by the backend's own tests.
      final after = await billing.membership();
      expect(after.state, 'inactive');
      expect(after.isActive, isFalse);
    });

    test('an application reaches the server, with both documents', () async {
      if (!serverIsUp) return;

      final certificate = File('${Directory.systemTemp.path}/live_licence.pdf')
        ..writeAsStringSync('%PDF-1.4 live test');
      final identity = File('${Directory.systemTemp.path}/live_nin.jpg')
        ..writeAsBytesSync([255, 216, 255, 0]);
      addTearDown(() {
        for (final file in [certificate, identity]) {
          if (file.existsSync()) file.deleteSync();
        }
      });

      final applications = ApiExpertApplicationRepository(api);
      final sent = await applications.submit(
        fullName: 'Live Tester',
        fields: {ExpertField.therapist, ExpertField.yoga},
        languages: {ExpertLanguage.english},
        experienceYears: 6,
        about: 'Written by the live test.',
        licenceNumber: 'NG-LIVE-1',
        certificationPath: certificate.path,
        identityPath: identity.path,
      );

      expect(sent.status, 'submitted');
      // Both disciplines survived the multipart form -- the thing that
      // silently dropped one before.
      expect(sent.fields, {ExpertField.therapist, ExpertField.yoga});

      final mine = await applications.mine();
      expect(mine.first.isPending, isTrue);
      expect(mine.first.statusLabel, isNotEmpty);
    });

    test('the practitioner screens are closed to a client', () async {
      if (!serverIsUp) return;

      // A 403 rather than an empty dashboard: an empty dashboard looks
      // like a bug, and this account is simply not a practitioner.
      await expectLater(
        ApiExpertRepository(api).earnings(),
        throwsA(anything),
      );
    });

    test('the account can be read and renamed', () async {
      if (!serverIsUp) return;
      final profiles = ApiProfileRepository(api);

      final before = await profiles.me();
      expect(before.email, isNotEmpty);

      final after = await profiles.update(fullName: 'Renamed Tester');

      expect(after.fullName, 'Renamed Tester');
      expect((await profiles.me()).fullName, 'Renamed Tester');
    });

    test('notifications can be counted and marked read', () async {
      if (!serverIsUp) return;
      final notifications = ApiNotificationRepository(api);

      // Nothing has happened to this account yet.
      expect(await notifications.unreadCount(), 0);
      await notifications.markRead();

      final switches = await notifications.preferences();
      expect(switches['notify_offers'], isFalse);
      await notifications.savePreference('notify_offers', true);
      expect((await notifications.preferences())['notify_offers'], isTrue);
    });

    test('the feed is empty rather than broken', () async {
      if (!serverIsUp) return;

      expect(await ApiNotificationRepository(api).feed(), isEmpty);
    });

    test('studios list, and a distance appears once a position is given',
        () async {
      if (!serverIsUp) return;
      final spaces = ApiSpacesRepository(api);

      final all = await spaces.spaces();
      final near = await spaces.spaces(latitude: 6.4281, longitude: 3.4219);

      expect(all, isNotEmpty, reason: 'no studios seeded');
      expect(all.first.distanceKm, isNull);
      expect(near.first.distanceKm, isNotNull);
    });

    test('the Passport waitlist takes an address once', () async {
      if (!serverIsUp) return;
      final spaces = ApiSpacesRepository(api);
      final address = 'passport.${DateTime.now().microsecondsSinceEpoch}@example.com';

      expect(await spaces.joinPassportWaitlist(address, city: 'Lagos'), isTrue);
      // Asking again is not an error, and says so.
      expect(await spaces.joinPassportWaitlist(address), isFalse);
    });

    test('a corporate enquiry is accepted', () async {
      if (!serverIsUp) return;

      await ApiCorporateRepository(api).send(
        company: 'Landmark Enterprise',
        contactName: 'Mr Felix',
        email: 'felix@landmark.example',
        phone: '+2348030000000',
        employees: '15',
      );
      // No throw is the assertion: the server answers 201 or raises.
    });

    test('matching, booking and the hold that follows', () async {
      if (!serverIsUp) return;
      final bookings = ApiBookingRepository(api);

      final expert = await bookings.match(discipline: 'therapy');
      expect(expert, isNotNull, reason: 'no expert seeded');
      expect(expert!.matchPercent, greaterThan(0));

      final slots = await bookings.freeSlots(expert.id);
      expect(slots, isNotEmpty, reason: 'no availability seeded');

      final slot = slots.first;
      final session = await bookings.book(
        discipline: 'therapy',
        day: slot.day,
        startMinute: slot.startMinute,
        expertId: expert.id,
      );

      // Booking holds the hour; paying is what confirms it.
      expect(session.awaitingPayment, isTrue);
      expect(session.priceNaira, 25000);
      expect(session.expertName, isNotEmpty);

      // And that hour is no longer offered to anyone else.
      final after = await bookings.freeSlots(expert.id);
      expect(
        after.any((s) =>
            s.day == slot.day && s.startMinute == slot.startMinute),
        isFalse,
      );

      final mine = await bookings.mySessions();
      expect(mine.map((s) => s.id), contains(session.id));

      final cancelled = await bookings.cancel(session.id);
      expect(cancelled.status, 'cancelled');
    });

    test('a session that was never booked cannot be paid for', () async {
      if (!serverIsUp) return;

      // Somebody else's id, or one that never existed.
      await expectLater(
        ApiBillingRepository(api).paySession('999999'),
        throwsA(anything),
      );
    });

    test('an expired access token refreshes itself', () async {
      if (!serverIsUp) return;

      // A token that is structurally fine but not ours: the server answers
      // 401, the client refreshes with the good refresh token, and the
      // caller never sees the failure.
      await PrefUtils().setTokens(
        access: 'not.a.token',
        refresh: PrefUtils().refreshToken,
      );

      final stats = await ApiProfileRepository(api).getStats();

      expect(stats.pilatesMinutes, 0);
      expect(PrefUtils().accessToken, isNot('not.a.token'));
    });
  });
}
