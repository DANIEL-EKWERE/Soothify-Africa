import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/network/api_client.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/expert_application.dart';
import 'package:soothifyafrica/app/data/models/expert_session.dart';
import 'package:soothifyafrica/app/data/models/user_role.dart';
import 'package:soothifyafrica/app/data/repositories/api_auth_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_expert_application_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_expert_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_notification_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_profile_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_billing_repository.dart';

/// The half of each call that lives in this app: the path it asks for, what
/// it sends, and what it makes of the answer.
///
/// No server is reached — a MockClient answers with the shapes Django's own
/// serializers produce. The other half, that the server answers that way, is
/// covered by `test/live_api_test.dart` and by the backend's own suite.
void main() {
  setUp(() {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  ({List<http.Request> sent, ApiClient api}) clientAnswering(
    FutureOr<http.Response> Function(http.Request) answer,
  ) {
    final sent = <http.Request>[];
    return (
      sent: sent,
      api: ApiClient(
        baseUrl: 'https://example.test/api/v1',
        accessToken: () => 'jwt-abc',
        refreshToken: () => '',
        client: MockClient((request) async {
          sent.add(request);
          return await answer(request);
        }),
      ),
    );
  }

  /// A multipart body as text.
  ///
  /// `request.body` decodes as UTF-8 and throws on the raw bytes of a PNG
  /// or a JPEG; latin1 maps every byte to a character, so the form fields
  /// stay readable and the file bytes are just noise around them.
  String multipart(http.Request request) => latin1.decode(request.bodyBytes);

  http.Response json(Object body, [int code = 200]) =>
      http.Response(jsonEncode(body), code, headers: const {
        'content-type': 'application/json',
      });

  // ------------------------------------------------------------- accounts

  group('accounts', () {
    const session = {
      'tokens': {'access': 'jwt-new', 'refresh': 'refresh-new'},
      'profile': {
        'role': 'user',
        'full_name': 'Ada Obi',
        'email': 'ada@example.com',
        'kyc_complete': true,
      },
    };

    test('registering keeps the session it is given', () async {
      await PrefUtils().init();
      final c = clientAnswering((_) => json(session, 201));

      final user = await ApiAuthRepository(c.api).register(
        fullName: ' Ada Obi ',
        email: ' ADA@example.com ',
        password: 'Soothify2026',
      );

      expect(jsonDecode(c.sent.single.body), {
        // Trimmed: a trailing space from a keyboard is not part of a name
        // or an address.
        'full_name': 'Ada Obi',
        'email': 'ADA@example.com'.trim(),
        'password': 'Soothify2026',
      });
      expect(user.role, UserRole.user);
      // Carried with the session, so the screen that follows is chosen
      // without a second round trip.
      expect(user.kycComplete, isTrue);
      expect(PrefUtils().accessToken, 'jwt-new');
      expect(PrefUtils().refreshToken, 'refresh-new');
    });

    test('signing in as a practitioner says so', () async {
      await PrefUtils().init();
      final c = clientAnswering((_) => json({
            'tokens': {'access': 'a', 'refresh': 'r'},
            'profile': {'role': 'practitioner'},
          }));

      final user = await ApiAuthRepository(c.api)
          .signIn(email: 'coach@example.com', password: 'x');

      expect(user.role, UserRole.practitioner);
      expect(c.sent.single.url.path, endsWith('/auth/login/'));
    });

    test('a session with no tokens is refused rather than half-kept',
        () async {
      await PrefUtils().init();
      final c = clientAnswering((_) => json({'profile': {'role': 'user'}}));

      await expectLater(
        ApiAuthRepository(c.api).signIn(email: 'a@b.co', password: 'x'),
        throwsA(isA<AppException>()),
      );
      expect(PrefUtils().accessToken, isEmpty);
    });

    test('signing out forgets the tokens even when the server cannot be told',
        () async {
      await PrefUtils().init();
      await PrefUtils().setTokens(access: 'a', refresh: 'r');
      final c = clientAnswering((_) => json({'detail': 'nope'}, 500));

      await ApiAuthRepository(c.api).signOut();

      // A server that cannot be reached must not be able to keep somebody
      // signed in on their own phone.
      expect(PrefUtils().accessToken, isEmpty);
      expect(PrefUtils().refreshToken, isEmpty);
    });

    test('deleting an account ends the session on this device', () async {
      await PrefUtils().init();
      await PrefUtils().setTokens(access: 'a', refresh: 'r');
      final c = clientAnswering((_) => http.Response('', 204));

      await ApiAuthRepository(c.api).deleteAccount('Soothify2026');

      expect(c.sent.single.url.path, endsWith('/auth/me/delete/'));
      // The server asks for proof it is them before erasing anything.
      expect(jsonDecode(c.sent.single.body), {'confirm': 'Soothify2026'});
      expect(PrefUtils().accessToken, isEmpty);
    });

    test('a refused confirmation leaves the session alone', () async {
      await PrefUtils().init();
      await PrefUtils().setTokens(access: 'a', refresh: 'r');
      final c = clientAnswering(
        (_) => json({'confirm': ['That password is not right.']}, 400),
      );

      await expectLater(
        ApiAuthRepository(c.api).deleteAccount('wrong'),
        throwsA(isA<AppException>()),
      );
      // Nothing was deleted, so nothing should be signed out of.
      expect(PrefUtils().accessToken, 'a');
    });

    test('an address already taken is reported as unavailable', () async {
      final c = clientAnswering((_) => json({'available': false}));

      expect(
        await ApiAuthRepository(c.api).emailAvailable('ada@example.com'),
        isFalse,
      );
      expect(c.sent.single.url.query, 'email=ada%40example.com');
    });

    test('a reset asks for a code and says nothing about who has an account',
        () async {
      final c = clientAnswering(
        (_) => json({'detail': 'If that address has an account, a code is on its way.'}),
      );

      await ApiAuthRepository(c.api).requestPasswordReset('ada@example.com');

      expect(c.sent.single.url.path, endsWith('/auth/password/reset/'));
      expect(jsonDecode(c.sent.single.body), {'email': 'ada@example.com'});
    });

    test('finishing a reset signs them in', () async {
      await PrefUtils().init();
      final c = clientAnswering((_) => json(session));

      final user = await ApiAuthRepository(c.api).confirmPasswordReset(
        email: 'ada@example.com',
        code: '123456',
        password: 'Soothify2026',
      );

      expect(user.role, UserRole.user);
      expect(PrefUtils().accessToken, 'jwt-new');
    });
  });

  group('the profile', () {
    test('only the fields that changed are sent', () async {
      final c = clientAnswering((_) => json({'id': 1, 'full_name': 'Ada O'}));

      await ApiProfileRepository(c.api).update(fullName: ' Ada O ');

      expect(c.sent.single.method, 'PATCH');
      // A PATCH, and only the one field: editing a name must not blank a
      // language nobody touched.
      expect(jsonDecode(c.sent.single.body), {'full_name': 'Ada O'});
    });

    test('a portrait goes up as a file, not as JSON', () async {
      final file = File('${Directory.systemTemp.path}/avatar_test.png')
        ..writeAsBytesSync([137, 80, 78, 71]);
      addTearDown(() => file.existsSync() ? file.deleteSync() : null);

      final c = clientAnswering(
        (_) => json({'id': 1, 'avatar_url': 'https://cdn/x.png?sig=1'}),
      );

      final me = await ApiProfileRepository(c.api).uploadAvatar(file.path);

      final request = c.sent.single;
      expect(request.method, 'PATCH');
      expect(request.headers['content-type'], contains('multipart/form-data'));
      expect(multipart(request), contains('name="avatar"'));
      // Read back as a signed link, never as the stored path.
      expect(me.avatarUrl, startsWith('https://'));
    });
  });

  group('notifications', () {
    test('the bell asks for a count rather than counting a page', () async {
      final c = clientAnswering((_) => json({'unread': 3}));

      expect(await ApiNotificationRepository(c.api).unreadCount(), 3);
    });

    test('one row, or the whole feed', () async {
      final c = clientAnswering((_) => json({'marked': 1}));
      final repository = ApiNotificationRepository(c.api);

      await repository.markRead(id: '7');
      await repository.markRead();

      expect(c.sent.first.url.path, endsWith('/notifications/7/read/'));
      expect(c.sent.last.url.path, endsWith('/notifications/read/'));
    });

    test('a switch is saved one at a time', () async {
      final c = clientAnswering((_) => json({'notify_offers': false}));

      await ApiNotificationRepository(c.api)
          .savePreference('notify_offers', false);

      expect(c.sent.single.method, 'PATCH');
      // One switch, because that is how they are pressed: a partial save of
      // four is worse than a failed save of one.
      expect(jsonDecode(c.sent.single.body), {'notify_offers': false});
    });
  });

  group('changing the card', () {
    test('opens a checkout for the check, not for the plan', () async {
      final c = clientAnswering(
        (_) => json({
          'reference': 'chk_2',
          'checkout_url': 'https://pay.bachs.io/c/3',
          'amount_naira': 100,
          'card_check': true,
          'card_check_naira': 100,
          'due_today_naira': 0,
        }, 201),
      );

      final checkout = await ApiBillingRepository(c.api).replaceCard();

      expect(c.sent.single.url.path, endsWith('/billing/card/'));
      expect(checkout.cardCheckNaira, 100);
      // Nothing is being bought: the check goes straight back.
      expect(checkout.dueTodayNaira, 0);
    });
  });

  group('listening', () {
    test('a finished listen is reported with its seconds', () async {
      final c = clientAnswering((_) => http.Response('', 204));

      await ApiContentRepository(c.api)
          .recordPlay('3', secondsListened: 540, completed: true);

      expect(c.sent.single.url.path, endsWith('/content/items/3/plays/'));
      expect(jsonDecode(c.sent.single.body), {
        'seconds_played': 540,
        'completed': true,
      });
    });

    test('rating is a PUT, so rating again changes the score', () async {
      final c = clientAnswering((_) => json({'id': 3, 'rating': 4.5}));

      final average = await ApiContentRepository(c.api).rate('3', 5);

      expect(c.sent.single.method, 'PUT');
      expect(jsonDecode(c.sent.single.body), {'score': 5});
      // The item's new average, which is what the screen shows afterwards.
      expect(average, 4.5);
    });
  });

  // ---------------------------------------------------------- the expert

  group('applying to practise', () {
    late File certificate;
    late File identity;

    setUp(() {
      certificate = File('${Directory.systemTemp.path}/licence_test.pdf')
        ..writeAsStringSync('%PDF-1.4');
      identity = File('${Directory.systemTemp.path}/nin_test.jpg')
        ..writeAsBytesSync([255, 216, 255]);
    });

    tearDown(() {
      for (final file in [certificate, identity]) {
        if (file.existsSync()) file.deleteSync();
      }
    });

    Future<void> apply(ApiClient api) =>
        ApiExpertApplicationRepository(api).submit(
          fullName: 'Dera Eze',
          fields: {ExpertField.therapist, ExpertField.yoga},
          languages: {ExpertLanguage.english, ExpertLanguage.pidgin},
          experienceYears: 6,
          about: 'Ten years in private practice.',
          licenceNumber: 'NG-PSY-4421',
          certificationPath: certificate.path,
          identityPath: identity.path,
        );

    test('the form and both documents go up together', () async {
      final c = clientAnswering(
        (_) => json({'id': 1, 'status': 'submitted', 'disciplines': []}, 201),
      );

      await apply(c.api);

      final body = multipart(c.sent.single);
      expect(c.sent.single.headers['content-type'],
          contains('multipart/form-data'));
      // Both files travel with the form: an application missing them cannot
      // be reviewed, so a two-step upload would leave half-applications.
      expect(body, contains('name="certification"'));
      expect(body, contains('name="identity"'));
      expect(body, contains('NG-PSY-4421'));
    });

    test('two disciplines are sent as the server reads them', () async {
      final c = clientAnswering(
        (_) => json({'id': 1, 'status': 'submitted'}, 201),
      );

      await apply(c.api);

      final body = multipart(c.sent.single);
      // One field, comma-joined, which is what the server splits. Sent as
      // a repeated key it would arrive as a *file* and the form would read
      // as empty -- see ApiClient.upload.
      expect('name="disciplines"'.allMatches(body).length, 1);
      expect(body, contains('therapy,yoga'));
      // The server's own words: "Certified Yoga Instructor" is a label,
      // not a discipline.
      expect(body, isNot(contains('Certified Yoga Instructor')));
    });

    test('an application that was sent reads back with its status', () async {
      final c = clientAnswering(
        (_) => json([
          {
            'id': 2,
            'status': 'reviewing',
            'status_display': 'Being reviewed',
            'disciplines': ['therapy'],
            'created_at': '2026-10-02T09:00:00Z',
          },
        ]),
      );

      final mine = await ApiExpertApplicationRepository(c.api).mine();

      expect(mine.single.statusLabel, 'Being reviewed');
      expect(mine.single.isPending, isTrue);
      expect(mine.single.fields, {ExpertField.therapist});
    });
  });

  group('the practitioner', () {
    test('the dashboard lists what is booked, soonest first', () async {
      final c = clientAnswering(
        (_) => json({'results': [
          {
            'id': 2,
            'client_name': 'Dami',
            'discipline': 'therapy',
            'starts_at': '2026-10-20T15:00:00Z',
            'ends_at': '2026-10-20T16:00:00Z',
          },
          {
            'id': 1,
            'client_name': 'Ada',
            'discipline': 'yoga',
            'starts_at': '2026-10-19T09:00:00Z',
            'ends_at': '2026-10-19T10:00:00Z',
          },
        ]}),
      );

      final sessions = await ApiExpertRepository(c.api).upcomingSessions();

      expect(c.sent.single.url.query, 'upcoming=true');
      expect(sessions.map((s) => s.clientName), ['Ada', 'Dami']);
      // The server's key, in the words the card prints.
      expect(sessions.last.service, '1-on-1 Therapy');
    });

    test('earnings come with the payouts beneath them', () async {
      final c = clientAnswering((request) {
        if (request.url.path.endsWith('/payouts/')) {
          return json({'results': [
            {
              'id': 1,
              'label': 'Weekly payout',
              'amount_naira': 25000,
              'paid_on': '2026-10-10',
            },
          ]});
        }
        return json({
          'available': 120000,
          'this_week': 50000,
          'this_week_sessions': 2,
          'total_earned': 300000,
          'total_sessions': 12,
          'next_payout': '2026-10-23',
          'payout_method': 'GTBank ****6789',
        });
      });

      final earnings = await ApiExpertRepository(c.api).earnings();

      expect(earnings.available, 120000);
      expect(earnings.payoutMethod, 'GTBank ****6789');
      expect(earnings.payouts.single.amount, 25000);
    });

    test('an account is added through the provider, and only its tail kept',
        () async {
      final c = clientAnswering(
        (_) => json({
          'id': 1,
          'bank_name': 'GTBank',
          'account_name': 'DERA EZE',
          'last4': '6789',
        }, 201),
      );

      final added = await ApiExpertRepository(c.api).addPayoutDestination(
        bankName: 'GTBank',
        bankCode: '058',
        accountNumber: '0123456789',
      );

      expect(jsonDecode(c.sent.single.body), {
        'kind': 'bank',
        'bank_name': 'GTBank',
        'bank_code': '058',
        'account_number': '0123456789',
        'is_default': true,
      });
      // The bank's own name on the account, and four digits of it.
      expect(added.accountName, 'DERA EZE');
      expect(added.masked, 'Bank ****6789');
    });

    test('a withdrawal asks only for an amount', () async {
      final c = clientAnswering((_) => json({'id': 1, 'status': 'pending'}, 201));

      await ApiExpertRepository(c.api).requestPayout(20000);

      // Where it goes is not the caller's to choose: it is the account on
      // file, which was verified with the bank when it was added.
      expect(jsonDecode(c.sent.single.body), {'amount_naira': 20000});
    });

    test('saving a week closes what was dropped and opens what is new',
        () async {
      final c = clientAnswering((request) {
        if (request.method == 'GET') {
          return json([
            {'id': 1, 'day': '2026-10-19', 'start_minute': 540, 'end_minute': 600},
            {'id': 2, 'day': '2026-10-20', 'start_minute': 540, 'end_minute': 600},
          ]);
        }
        return json({
          'id': 9, 'day': '2026-10-21', 'start_minute': 660, 'end_minute': 720,
        }, 201);
      });

      await ApiExpertRepository(c.api).saveAvailability([
        // Kept as it is.
        AvailabilitySlot(
          id: '1', day: DateTime(2026, 10, 19), from: 540, to: 600,
        ),
        // New, so it has no id yet.
        AvailabilitySlot(
          id: '', day: DateTime(2026, 10, 21), from: 660, to: 720,
        ),
      ]);

      final methods = c.sent.map((r) => '${r.method} ${r.url.path}').toList();
      // The one that was dropped is closed; the new one is opened; the one
      // that did not change is left alone.
      expect(methods, contains('DELETE /api/v1/experts/me/availability/2/'));
      expect(methods, contains('POST /api/v1/experts/me/availability/'));
      expect(
        methods.where((m) => m.contains('availability/1/')),
        isEmpty,
      );
    });

    test('a session with no note yet reads as empty, not as an error',
        () async {
      final c = clientAnswering((_) => json({'detail': 'not found'}, 404));

      expect(await ApiExpertRepository(c.api).sessionNote('11'), '');
    });

    test('a note is written against its session', () async {
      final c = clientAnswering((_) => json({'body': 'Settled well.'}));

      await ApiExpertRepository(c.api).saveSessionNote('11', 'Settled well.');

      expect(c.sent.single.method, 'PUT');
      expect(c.sent.single.url.path, endsWith('/sessions/11/note/'));
      expect(jsonDecode(c.sent.single.body), {'body': 'Settled well.'});
    });
  });
}
