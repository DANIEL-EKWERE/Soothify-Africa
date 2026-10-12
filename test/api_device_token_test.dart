import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/network/api_client.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/repositories/api_device_token_repository.dart';

/// The Django endpoint is `POST /api/v1/notifications/devices/`, taking
/// `{token, platform}` behind SimpleJWT. It is not deployed yet, so every
/// test here drives a MockClient: what is checked is the request this app
/// sends and what it does with each answer, which is the half that has to be
/// right before the server exists.
void main() {
  setUp(() async {
    PrefUtils.resetForTesting();
    SharedPreferences.setMockInitialValues({});
    await PrefUtils().init();
  });

  /// Captures the one request made, so a test can assert on it.
  ({List<http.Request> sent, ApiClient api}) clientAnswering(
    http.Response Function(http.Request) answer, {
    String token = 'jwt-abc',
  }) {
    final sent = <http.Request>[];
    final api = ApiClient(
      baseUrl: 'https://example.test/api/v1',
      accessToken: () => token,
      client: MockClient((request) async {
        sent.add(request);
        return answer(request);
      }),
    );
    return (sent: sent, api: api);
  }

  group('the API client', () {
    test('sends JSON with the bearer token', () async {
      final c = clientAnswering((_) => http.Response('{"ok":true}', 200));
      await c.api.post('/notifications/devices/', body: {'token': 'fcm-1'});

      final request = c.sent.single;
      expect(request.method, 'POST');
      expect(
        request.url.toString(),
        'https://example.test/api/v1/notifications/devices/',
      );
      expect(request.headers['Authorization'], 'Bearer jwt-abc');
      expect(request.headers['Content-Type'], contains('application/json'));
      expect(jsonDecode(request.body), {'token': 'fcm-1'});
    });

    test('omits the header entirely when there is no token', () async {
      final c = clientAnswering(
        (_) => http.Response('{}', 200),
        token: '',
      );
      await c.api.post('/health/');
      // Not an empty "Bearer ", which DRF would try to parse and reject.
      expect(c.sent.single.headers.containsKey('Authorization'), isFalse);
    });

    test('turns DRF status codes into the app\'s own failures', () async {
      Future<Object?> failureFor(int code, [String body = '{}']) async {
        final c = clientAnswering((_) => http.Response(body, code));
        try {
          await c.api.post('/x/');
          return null;
        } on AppException catch (e) {
          return e;
        }
      }

      expect(await failureFor(401), isA<UnauthorizedException>());
      expect(await failureFor(403), isA<UnauthorizedException>());
      expect(await failureFor(404), isA<NotFoundException>());
      expect(await failureFor(500), isA<ServerException>());
      expect(await failureFor(503), isA<ServerException>());
    });

    /// DRF answers a bad field with {"field": ["msg"]}; a form needs the
    /// per-field messages, not just a sentence.
    test('carries DRF field errors through', () async {
      final failure = await () async {
        final c = clientAnswering(
          (_) => http.Response(
            '{"platform":["\\"Android\\" is not a valid choice."]}',
            400,
          ),
        );
        try {
          await c.api.post('/notifications/devices/');
          return null;
        } on ValidationException catch (e) {
          return e;
        }
      }();

      expect(failure, isNotNull);
      expect(failure!.message, contains('not a valid choice'));
      expect(failure.fieldErrors['platform'], hasLength(1));
    });

    test('an empty 204 body is not a parse error', () async {
      final c = clientAnswering((_) => http.Response('', 204));
      expect(await c.api.delete('/notifications/devices/'), isEmpty);
    });
  });

  group('registering this device', () {
    test('sends the token and the lowercase platform', () async {
      final c = clientAnswering((_) => http.Response('{}', 201));
      await PrefUtils().setTokens(access: 'jwt-abc', refresh: 'r');

      await ApiDeviceTokenRepository(c.api).register(
        token: 'fcm-xyz',
        // The service hands it over already lowercased; this proves the
        // repository would not undo that. PushDevice.PLATFORMS has no
        // "Android".
        platform: 'Android',
        deviceModel: 'TECNO BG6',
        appVersion: '13',
      );

      expect(jsonDecode(c.sent.single.body), {
        'token': 'fcm-xyz',
        'platform': 'android',
      });
      // Recorded, so an unchanged token is not re-sent next launch.
      expect(PrefUtils().deviceToken, 'fcm-xyz');
    });

    /// The app's sign-in does not reach the backend yet, so this is the
    /// normal path today: hold the token, send nothing, retry later.
    test('skips, without throwing, when there is no session', () async {
      final c = clientAnswering((_) => http.Response('{}', 201), token: '');

      await ApiDeviceTokenRepository(c.api).register(
        token: 'fcm-xyz',
        platform: 'android',
        deviceModel: 'TECNO BG6',
        appVersion: '13',
      );

      expect(c.sent, isEmpty);
      // Empty, not stored: PushService skips an unchanged token, so storing
      // one that never reached the server would never be retried.
      expect(PrefUtils().deviceToken, isEmpty);
    });

    test('a server failure leaves the token unsent, so it is retried',
        () async {
      final c = clientAnswering((_) => http.Response('{}', 500));
      await PrefUtils().setTokens(access: 'jwt-abc', refresh: 'r');

      // Does not throw: a failed registration must not break a launch.
      await ApiDeviceTokenRepository(c.api).register(
        token: 'fcm-xyz',
        platform: 'android',
        deviceModel: 'TECNO BG6',
        appVersion: '13',
      );

      expect(c.sent, hasLength(1));
      expect(PrefUtils().deviceToken, isEmpty);
    });

    test('signing out deletes the registration and forgets the token',
        () async {
      final c = clientAnswering((_) => http.Response('', 204));
      await PrefUtils().setTokens(access: 'jwt-abc', refresh: 'r');
      await PrefUtils().setDeviceToken('fcm-xyz');

      await ApiDeviceTokenRepository(c.api).unregister();

      expect(c.sent.single.method, 'DELETE');
      expect(jsonDecode(c.sent.single.body), {'token': 'fcm-xyz'});
      expect(PrefUtils().deviceToken, isEmpty);
    });

    test('nothing to unregister is not a request', () async {
      final c = clientAnswering((_) => http.Response('', 204));
      await ApiDeviceTokenRepository(c.api).unregister();
      expect(c.sent, isEmpty);
    });
  });

  /// Credentials are the session; a push token is the install and outlives
  /// it. Clearing the wrong one logs the next person in, or loses push.
  test('clearing the session drops the JWTs and keeps the push token',
      () async {
    await PrefUtils().setTokens(access: 'jwt-abc', refresh: 'r');
    await PrefUtils().setDeviceToken('fcm-xyz');

    await PrefUtils().clearSession();

    expect(PrefUtils().accessToken, isEmpty);
    expect(PrefUtils().refreshToken, isEmpty);
    expect(PrefUtils().deviceToken, 'fcm-xyz');
  });
}
