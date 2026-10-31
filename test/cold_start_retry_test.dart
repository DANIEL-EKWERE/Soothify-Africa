import 'dart:async' as async;
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/network/api_client.dart';

/// The cold start.
///
/// The shared host starts the Python application on the first request
/// after it has been idle, and that can outlast the twenty-second
/// timeout. So opening the app showed "That took too long. Please try
/// again." and the pull-to-refresh straight after worked — because the
/// server was warm by then. One retry is the difference.
///
/// What must not be retried is anything that changes something: a timeout
/// does not mean the request failed to arrive, only that the reply did,
/// and sending a booking twice books two hours.
class _Flaky extends http.BaseClient {
  _Flaky({required this.failFirst, this.body = '{}'});

  /// How many attempts time out before one succeeds.
  int failFirst;
  final String body;

  final attempts = <String>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    attempts.add('${request.method} ${request.url.path}');
    if (failFirst > 0) {
      failFirst -= 1;
      // What a request that never comes back looks like from here.
      await Future<void>.delayed(const Duration(days: 1));
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      200,
      request: request,
    );
  }
}

void main() {
  ApiClient clientWith(_Flaky transport) => ApiClient(
        client: transport,
        baseUrl: 'https://example.test/api/v1',
        accessToken: () => '',
        refreshToken: () => '',
        // The real twenty seconds, twice over, outlasts the test
        // framework's own limit. What is under test is the retrying, not
        // the length of the wait.
        timeout: const Duration(milliseconds: 80),
      );

  test('a read that times out once is tried again', () async {
    final transport = _Flaky(failFirst: 1, body: '{"ok":true}');

    final body = await clientWith(transport).get('/content/popular/');

    expect(body['ok'], isTrue);
    expect(transport.attempts.length, 2, reason: 'it did not try again');
  });

  test('a read that keeps timing out still says so', () async {
    final transport = _Flaky(failFirst: 5);

    await expectLater(
      clientWith(transport).get('/content/popular/'),
      throwsA(isA<TimeoutException>()),
    );
    // Once more, not forever.
    expect(transport.attempts.length, 2);
  });

  test('a read-only POST is tried again too', () async {
    // The home screen's own call: the questionnaire travels in the body
    // to keep it out of access logs, so the verb says POST and the work
    // is a read.
    final transport = _Flaky(failFirst: 1, body: '{"results":[]}');

    await clientWith(transport)
        .post('/content/recommendations/', body: const {}, reads: true);

    expect(transport.attempts.length, 2);
  });

  test('a POST that changes something is never tried again', () async {
    // The one that matters. A timeout does not mean the booking failed to
    // arrive; sending it again would hold two hours.
    final transport = _Flaky(failFirst: 1);

    await expectLater(
      clientWith(transport).post('/sessions/', body: const {'day': '2026-11-02'}),
      throwsA(isA<TimeoutException>()),
    );
    expect(transport.attempts.length, 1, reason: 'a booking was repeated');
  });

  test('a PUT is never tried again either', () async {
    final transport = _Flaky(failFirst: 1);

    await expectLater(
      clientWith(transport).put('/wellbeing/reminders/', body: const {}),
      throwsA(isA<TimeoutException>()),
    );
    expect(transport.attempts.length, 1);
  });

  test('a read that works first time is sent once', () async {
    final transport = _Flaky(failFirst: 0, body: '{"ok":true}');

    await clientWith(transport).get('/content/popular/');

    expect(transport.attempts.length, 1);
  });
}
