import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/network/api_client.dart';
import 'package:soothifyafrica/app/data/models/app_notification.dart';
import 'package:soothifyafrica/app/data/models/plan_tier.dart';
import 'package:soothifyafrica/app/data/repositories/api_billing_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_booking_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_corporate_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_spaces_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_notification_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_profile_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_subscription_repository.dart';

/// The repositories that read from Django, and the client underneath them.
///
/// No server is reached: a MockClient answers with the shapes the backend's
/// own serializers produce. What is pinned here is the half that lives in
/// this app — the paths it calls, and what it makes of each answer.
void main() {
  /// A client whose answers are chosen per request path.
  ({List<http.Request> sent, ApiClient api}) clientAnswering(
    // FutureOr: most answers are immediate, but the test for a shared
    // refresh needs a slow one to overlap six callers.
    FutureOr<http.Response> Function(http.Request) answer, {
    String token = 'jwt-abc',
    String refresh = '',
    void Function(String access, String refresh)? onTokens,
    void Function()? onSignedOut,
  }) {
    final sent = <http.Request>[];
    var access = token;
    final api = ApiClient(
      baseUrl: 'https://example.test/api/v1',
      accessToken: () => access,
      refreshToken: () => refresh,
      onTokens: (newAccess, newRefresh) async {
        access = newAccess;
        onTokens?.call(newAccess, newRefresh);
      },
      onSignedOut: () async => onSignedOut?.call(),
      client: MockClient((request) async {
        sent.add(request);
        return await answer(request);
      }),
    );
    return (sent: sent, api: api);
  }

  http.Response json(Object body, [int code = 200]) =>
      http.Response(jsonEncode(body), code, headers: const {
        'content-type': 'application/json',
      });

  group('list responses', () {
    test('a paginated page gives up its results', () async {
      final c = clientAnswering(
        (_) => json({'count': 2, 'results': [
          {'id': 1}, {'id': 2},
        ]}),
      );

      final rows = await c.api.getList('/content/items/');

      expect(rows, hasLength(2));
      expect(rows.first['id'], 1);
    });

    test('a bare array is read the same way', () async {
      // Unpaginated views -- featured, categories, shelves -- send a plain
      // list, and no caller should have to know which kind it asked for.
      final c = clientAnswering((_) => json([{'id': 7}]));

      final rows = await c.api.getList('/content/featured/');

      expect(rows.single['id'], 7);
    });

    test('an unexpected shape is empty rather than a crash', () async {
      final c = clientAnswering((_) => json({'detail': 'nothing here'}));

      expect(await c.api.getList('/content/featured/'), isEmpty);
    });
  });

  group('expired access tokens', () {
    test('are refreshed once and the request is retried', () async {
      var refreshed = false;
      var served = false;
      final c = clientAnswering(
        refresh: 'refresh-1',
        (request) async {
          if (request.url.path.endsWith('/auth/token/refresh/')) {
            refreshed = true;
            return json({'access': 'jwt-new', 'refresh': 'refresh-2'});
          }
          // 401 until the token has been refreshed, then the real answer.
          if (!refreshed) return json({'detail': 'expired'}, 401);
          served = true;
          return json({'meditation_minutes': 30});
        },
      );

      final stats = await ApiProfileRepository(c.api).getStats();

      expect(refreshed, isTrue);
      expect(served, isTrue);
      expect(stats.pilatesMinutes, 30);
      // The retry carries the new token, not the stale one.
      expect(c.sent.last.headers['Authorization'], 'Bearer jwt-new');
    });

    test('the rotated refresh token is handed back to be stored', () async {
      String? storedRefresh;
      final c = clientAnswering(
        refresh: 'refresh-1',
        onTokens: (_, newRefresh) => storedRefresh = newRefresh,
        (request) => request.url.path.endsWith('/auth/token/refresh/')
            ? json({'access': 'jwt-new', 'refresh': 'refresh-2'})
            : json({'detail': 'expired'}, 401),
      );

      await expectLater(
        ApiProfileRepository(c.api).getStats(),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(storedRefresh, 'refresh-2');
    });

    test('a dead refresh token ends the session once, not in a loop', () async {
      var signedOut = 0;
      var refreshCalls = 0;
      final c = clientAnswering(
        refresh: 'refresh-stale',
        onSignedOut: () => signedOut++,
        (request) {
          if (request.url.path.endsWith('/auth/token/refresh/')) {
            refreshCalls++;
            return json({'detail': 'token not valid'}, 401);
          }
          return json({'detail': 'expired'}, 401);
        },
      );

      await expectLater(
        ApiProfileRepository(c.api).getStats(),
        throwsA(isA<UnauthorizedException>()),
      );

      expect(signedOut, 1);
      expect(refreshCalls, 1);
    });

    test('nothing is refreshed when there is no refresh token', () async {
      // A signed-out browser hitting an authenticated endpoint: one request,
      // one 401, no pointless round trip.
      final c = clientAnswering((_) => json({'detail': 'no'}, 401));

      await expectLater(
        ApiProfileRepository(c.api).getStats(),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(c.sent, hasLength(1));
    });

    test('six screens at once share one refresh', () async {
      var refreshCalls = 0;
      var refreshed = false;
      final c = clientAnswering(
        refresh: 'refresh-1',
        (request) async {
          if (request.url.path.endsWith('/auth/token/refresh/')) {
            refreshCalls++;
            await Future<void>.delayed(const Duration(milliseconds: 10));
            refreshed = true;
            return json({'access': 'jwt-new', 'refresh': 'refresh-2'});
          }
          return refreshed
              ? json({'meditation_minutes': 1})
              : json({'detail': 'expired'}, 401);
        },
      );

      final profile = ApiProfileRepository(c.api);
      await Future.wait(List.generate(6, (_) => profile.getStats()));

      // Six parallel refreshes would rotate the token six times, and five of
      // those would land on a refresh token already replaced.
      expect(refreshCalls, 1);
    });
  });

  group('the content repository', () {
    test('reads a card the way the app already parses it', () async {
      final c = clientAnswering(
        (_) => json([
          {
            'id': 3,
            'title': 'Daily focus',
            'media_type': 'audio',
            'duration_seconds': 2700,
            'cover_url': 'https://cdn/x.jpg',
            'media_url': 'https://cdn/x.mp3',
            'practitioner_name': 'Jacob Samuel',
            'is_free': true,
          },
        ]),
      );

      final items = await ApiContentRepository(c.api).getFeatured();

      final item = items.single;
      expect(item.id, '3');
      expect(item.title, 'Daily focus');
      expect(item.duration.inMinutes, 45);
      expect(item.practitionerName, 'Jacob Samuel');
    });

    test('a shelf asks for its own row and reads the envelope', () async {
      final c = clientAnswering(
        (_) => json({
          'key': 'voice-overs',
          'title': 'Voice overs',
          'items': [{'id': 1, 'title': 'First'}],
        }),
      );

      final items = await ApiContentRepository(c.api).getShelf('voice-overs');

      expect(c.sent.single.url.path, endsWith('/content/shelves/voice-overs/'));
      expect(c.sent.single.url.query, isEmpty);
      expect(items.single.title, 'First');
    });

    test('"See All" asks the same shelf for everything', () async {
      final c = clientAnswering((_) => json({'items': []}));

      await ApiContentRepository(c.api).getShelfPage('voice-overs');

      expect(c.sent.single.url.query, 'full=true');
    });

    test('an empty search asks the server nothing', () async {
      final c = clientAnswering((_) => json([]));

      expect(await ApiContentRepository(c.api).search('   '), isEmpty);
      expect(c.sent, isEmpty);
    });

    test('a search sends the term encoded', () async {
      final c = clientAnswering((_) => json([]));

      await ApiContentRepository(c.api).search('deep rest');

      // '+' rather than '%20': that is how a space is written in a query
      // string, and Django decodes it to a space either way.
      expect(c.sent.single.url.query, 'q=deep+rest');
    });
  });

  group('the KYC repository', () {
    test('reads answers back as sets', () async {
      final c = clientAnswering(
        (_) => json({
          'answers': {'gender': ['female'], 'brings_you': ['stress', 'sleep']},
          'is_complete': false,
        }),
      );

      final answers = await ApiKycRepository(c.api).savedAnswers();

      expect(answers['brings_you'], {'stress', 'sleep'});
    });

    test('saves them as lists, merged by the server', () async {
      final c = clientAnswering((_) => json({'answers': {}}));

      await ApiKycRepository(c.api).saveAnswers({'gender': {'female'}});

      expect(c.sent.single.method, 'PATCH');
      expect(
        jsonDecode(c.sent.single.body),
        {'answers': {'gender': ['female']}},
      );
    });

    test('an unanswered questionnaire is empty, not an error', () async {
      final c = clientAnswering((_) => json({'answers': {}, 'is_complete': false}));

      expect(await ApiKycRepository(c.api).savedAnswers(), isEmpty);
      expect(await ApiKycRepository(c.api).isComplete(), isFalse);
    });
  });

  group('the subscription repository', () {
    test('reads the plan cards', () async {
      final c = clientAnswering(
        (_) => json([
          {
            'id': 'core-annual',
            'name': 'Soothify Core',
            'description': 'Your sanctuary for daily balance.',
            'price_display': '₦150,000',
            'is_recommended': false,
          },
        ]),
      );

      final tiers = await ApiSubscriptionRepository(c.api)
          .getTiers(BillingPeriod.annual);

      expect(tiers.single.name, 'Soothify Core');
      expect(tiers.single.price, '₦150,000');
      expect(c.sent.single.url.query, 'period=annual');
    });
  });

  group('the notification repository', () {
    test('reads each kind the feed draws', () async {
      final c = clientAnswering(
        (_) => json({'results': [
          {
            'id': 1,
            'kind': 'reminder',
            'title': 'Reminder',
            'body': 'You have Yoga session today at 5:00pm',
            'emphasis': 'Yoga',
            'unread': true,
            'filters': ['sessions'],
            'created_at': '2026-10-12T09:00:00Z',
          },
        ]}),
      );

      final feed = await ApiNotificationRepository(c.api).feed();

      final row = feed.single;
      expect(row.emphasis, 'Yoga');
      expect(row.unread, isTrue);
      expect(row.filters, contains(NotificationFilter.sessions));
      // Everything is under "All", whatever else it is under.
      expect(row.filters, contains(NotificationFilter.all));
    });

    test('a kind this build does not know falls back to a plain line', () async {
      // The server may grow a kind before the app ships; a feed that throws
      // on one unknown row is worse than a row that renders plainly.
      final c = clientAnswering(
        (_) => json({'results': [
          {'id': 2, 'kind': 'something_new', 'text': 'Hello', 'filters': []},
        ]}),
      );

      final feed = await ApiNotificationRepository(c.api).feed();

      expect(feed.single.kind, NotificationKind.plain);
    });
  });

  group('the booking repository', () {
    test('a match asks for the discipline, and the time when one is chosen',
        () async {
      final c = clientAnswering((_) => json({'id': 4, 'match_percent': 92}));

      final expert = await ApiBookingRepository(c.api).match(
        discipline: 'therapy',
        day: DateTime(2026, 10, 19),
        startMinute: 540,
        language: 'pcm',
      );

      expect(expert!.matchPercent, 92);
      final query = c.sent.single.url.queryParameters;
      expect(query, {
        'discipline': 'therapy',
        // A local calendar date, not an instant: 9am on the 19th is 9am
        // wherever the phone is, and a UTC timestamp would move it.
        'day': '2026-10-19',
        'start_minute': '540',
        'language': 'pcm',
      });
    });

    test('nobody free is an empty answer, not an error', () async {
      // The calendar offers another time when this happens; a thrown
      // exception would put a red banner over a normal Tuesday.
      final c = clientAnswering((_) => json({'detail': 'no match'}, 404));

      expect(
        await ApiBookingRepository(c.api).match(discipline: 'yoga'),
        isNull,
      );
    });

    test('free slots come back as the hours the calendar draws', () async {
      final c = clientAnswering(
        (_) => json([
          {'id': 2, 'day': '2026-10-19', 'start_minute': 660, 'end_minute': 720},
        ]),
      );

      final slots = await ApiBookingRepository(c.api).freeSlots('4');

      expect(c.sent.single.url.path, endsWith('/experts/4/slots/'));
      expect(slots.single.startMinute, 660);
      expect(slots.single.day, DateTime(2026, 10, 19));
    });

    test('booking sends the slot, and the expert as a number', () async {
      final c = clientAnswering((_) => json({'id': 11, 'status': 'pending'}));

      final session = await ApiBookingRepository(c.api).book(
        discipline: 'therapy',
        day: DateTime(2026, 10, 19),
        startMinute: 540,
        expertId: '4',
      );

      expect(
        jsonDecode(c.sent.single.body),
        {
          'discipline': 'therapy',
          'day': '2026-10-19',
          'start_minute': 540,
          'mode': 'video',
          'plan': 'single',
          // The id is a string everywhere in the app and a primary key on the
          // server; sent as text, DRF would refuse it.
          'expert': 4,
        },
      );
      expect(session.awaitingPayment, isTrue);
    });

    test('an unpaid booking is pending, and a paid one is not', () async {
      final c = clientAnswering((_) => json({'id': 11, 'status': 'confirmed'}));

      final session = await ApiBookingRepository(c.api).book(
        discipline: 'therapy',
        day: DateTime(2026, 10, 19),
        startMinute: 540,
      );

      expect(session.awaitingPayment, isFalse);
      expect(session.isPaid, isTrue);
    });

    test('"My sessions" can ask for the upcoming ones alone', () async {
      final c = clientAnswering((_) => json({'results': []}));

      await ApiBookingRepository(c.api).mySessions(upcomingOnly: true);

      expect(c.sent.single.url.query, 'upcoming=true');
    });
  });

  group('the billing repository', () {
    test('reads where a membership stands', () async {
      final c = clientAnswering(
        (_) => json({
          'state': 'trial',
          'plan_key': 'core-annual',
          'plan_name': 'Soothify Core',
          'trial_ends_at': '2026-10-23T09:00:00Z',
          'card': 'Mastercard ending in 1234',
          'next_charge_naira': 150000,
          'is_active': true,
        }),
      );

      final membership = await ApiBillingRepository(c.api).membership();

      expect(membership.isOnTrial, isTrue);
      expect(membership.isActive, isTrue);
      expect(membership.card, 'Mastercard ending in 1234');
      expect(membership.trialEndsAt, isNotNull);
    });

    test('a free week granted outright has nothing to open', () async {
      // Sold a period at a time there is no card to save, so the server
      // starts the week itself and the app must not sit waiting on a
      // browser that will never open.
      final c = clientAnswering(
        (_) => json({
          'reference': '',
          'checkout_url': '',
          'amount_naira': 0,
          'trial_days': 7,
          'due_today_naira': 0,
          'trial_started': true,
        }, 201),
      );

      final checkout = await ApiBillingRepository(c.api)
          .startMembership(planKey: 'core-annual');

      expect(checkout.trialStarted, isTrue);
      expect(checkout.checkoutUrl, isEmpty);
    });

    test('a free week behind a card opens a checkout for the check, not the '
        'price of the plan', () async {
      final c = clientAnswering(
        (_) => json({
          'reference': 'chk_1',
          'checkout_url': 'https://pay.bachs.io/c/2',
          'amount_naira': 100,
          'trial_days': 7,
          'due_today_naira': 0,
          'card_check': true,
          'card_check_naira': 100,
          'trial_started': false,
        }, 201),
      );

      final checkout = await ApiBillingRepository(c.api)
          .startMembership(planKey: 'core-annual');

      expect(checkout.cardCheckNaira, 100);
      // Nothing is being bought, so nothing is due -- the hundred goes back.
      expect(checkout.dueTodayNaira, 0);
      expect(checkout.trialStarted, isFalse);
      expect(checkout.checkoutUrl, isNotEmpty);
    });

    test('the membership says what the week will ask for', () async {
      final c = clientAnswering(
        (_) => json({
          'state': 'inactive',
          'trial_available': true,
          'trial_requires_card': true,
          'card_check_naira': 100,
        }),
      );

      final membership = await ApiBillingRepository(c.api).membership();

      expect(membership.trialRequiresCard, isTrue);
      expect(membership.cardCheckNaira, 100);
    });

    test('a membership that does not renew itself says so', () async {
      final c = clientAnswering(
        (_) => json({
          'state': 'active',
          'plan_name': 'Soothify Core',
          'renews_at': '2027-10-09T09:00:00Z',
          'is_active': true,
          'auto_renew': false,
          'trial_available': false,
        }),
      );

      final membership = await ApiBillingRepository(c.api).membership();

      expect(membership.autoRenew, isFalse);
      expect(membership.trialAvailable, isFalse);
    });

    test('an older server that says neither is assumed to renew', () async {
      // Both fields arrived with one-period-at-a-time billing; a build
      // talking to a server without them should not start telling people
      // their membership is about to end.
      final c = clientAnswering((_) => json({'state': 'active'}));

      final membership = await ApiBillingRepository(c.api).membership();

      expect(membership.autoRenew, isTrue);
      expect(membership.trialAvailable, isTrue);
    });

    test('a checkout for a plan carries the trial flag', () async {
      final c = clientAnswering(
        (_) => json({
          'reference': 'ref_1',
          'checkout_url': 'https://pay.bachs.io/c/1',
          'amount_naira': 150000,
          'trial_days': 7,
          'due_today_naira': 0,
        }),
      );

      final checkout = await ApiBillingRepository(c.api)
          .startMembership(planKey: 'core-annual');

      expect(jsonDecode(c.sent.single.body), {
        'plan': 'core-annual',
        'cadence': 'annual',
        'trial': true,
      });
      expect(checkout.checkoutUrl, 'https://pay.bachs.io/c/1');
      // A free week charges nothing today, which is what the sheet says.
      expect(checkout.dueTodayNaira, 0);
      expect(checkout.trialDays, 7);
    });

    test('paying for a session posts against that session', () async {
      final c = clientAnswering((_) => json({'reference': 'ref_2'}));

      await ApiBillingRepository(c.api).paySession('11');

      expect(
        c.sent.single.url.path,
        endsWith('/billing/sessions/11/checkout/'),
      );
    });

    test('a payment not yet settled reads as pending', () async {
      // The poll runs while the provider's webhook is still in flight, and
      // an answer without a status must not look like a success.
      final c = clientAnswering((_) => json({}));

      expect(await ApiBillingRepository(c.api).paymentStatus('ref_2'), 'pending');
    });

    test('a promo code the server rejects is simply not valid', () async {
      final c = clientAnswering((_) => json({'valid': false}));

      expect(await ApiBillingRepository(c.api).checkPromo('NOPE'), isNull);
    });

    test('an unknown promo code is an answer, not a failure', () async {
      final c = clientAnswering((_) => json({'detail': 'no such code'}, 404));

      expect(await ApiBillingRepository(c.api).checkPromo('GHOST'), isNull);
    });

    test('reads the billing history', () async {
      final c = clientAnswering(
        (_) => json({'results': [
          {
            'id': 3,
            'amount_naira': 15000,
            'description': 'Soothify Core — monthly',
            'status_label': 'Paid (Mastercard 1234)',
            'paid_at': '2026-09-01T10:00:00Z',
          },
        ]}),
      );

      final rows = await ApiBillingRepository(c.api).invoices();

      expect(rows.single.statusLabel, 'Paid (Mastercard 1234)');
      expect(rows.single.amountNaira, 15000);
    });
  });

  group('the spaces repository', () {
    test('"All" is not a filter, and a search term is trimmed', () async {
      final c = clientAnswering((_) => json([]));

      await ApiSpacesRepository(c.api).spaces(category: 'all', query: '  spa ');

      expect(c.sent.single.url.queryParameters, {'q': 'spa'});
    });

    test('a position is sent so the server can measure the distance', () async {
      final c = clientAnswering(
        (_) => json([
          {'id': 'sage-and-she', 'name': 'Sage & She', 'area': 'Lekki',
           'distance_km': 3.42},
        ]),
      );

      final rows = await ApiSpacesRepository(c.api)
          .spaces(category: 'spa', latitude: 6.4281, longitude: 3.4219);

      expect(c.sent.single.url.queryParameters, {
        'category': 'spa',
        'lat': '6.4281',
        'lng': '3.4219',
      });
      expect(rows.single.distanceLabel, '3.4 km away');
    });

    test('without a position a card claims no distance at all', () async {
      final c = clientAnswering(
        (_) => json([{'id': 'x', 'name': 'Studio', 'area': 'Ikoyi'}]),
      );

      final rows = await ApiSpacesRepository(c.api).spaces();

      expect(rows.single.distanceKm, isNull);
      expect(rows.single.distanceLabel, isEmpty);
    });

    test('joining the Passport waitlist twice says so the second time',
        () async {
      final first = clientAnswering((_) => json({'already_on_list': false}, 201));
      final again = clientAnswering((_) => json({'already_on_list': true}));

      expect(
        await ApiSpacesRepository(first.api)
            .joinPassportWaitlist(' me@example.com ', city: 'Lagos'),
        isTrue,
      );
      expect(
        await ApiSpacesRepository(again.api).joinPassportWaitlist('me@example.com'),
        isFalse,
      );
      // Trimmed: a trailing space from the keyboard is not part of an address.
      expect(jsonDecode(first.sent.single.body)['email'], 'me@example.com');
    });
  });

  group('the corporate repository', () {
    test('sends the enquiry under the names the server reads', () async {
      final c = clientAnswering((_) => json({'id': 1}, 201));

      await ApiCorporateRepository(c.api).send(
        company: ' Landmark Enterprise ',
        contactName: 'Mr Felix',
        email: 'felix@landmark.example',
        phone: '+2348030000000',
        employees: '15',
        services: 'Therapy, Yoga',
      );

      expect(jsonDecode(c.sent.single.body), {
        'company': 'Landmark Enterprise',
        'contact_name': 'Mr Felix',
        'email': 'felix@landmark.example',
        'phone': '+2348030000000',
        'employees': '15',
        'services': 'Therapy, Yoga',
        'notes': '',
      });
    });
  });
}
