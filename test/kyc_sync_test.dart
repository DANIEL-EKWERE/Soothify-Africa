import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/network/api_client.dart';
import 'package:soothifyafrica/app/data/repositories/api_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/api_kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/kyc_repository.dart';
import 'package:soothifyafrica/app/data/repositories/syncing_kyc_repository.dart';

/// A KycRepository that keeps everything in memory, standing in for the
/// device's own storage.
class FakeLocalKyc implements KycRepository {
  Map<String, Set<String>> answers = {};
  bool complete = false;

  @override
  Future<Map<String, Set<String>>> savedAnswers() async => answers;

  @override
  Future<void> saveAnswers(Map<String, Set<String>> value) async {
    answers = value;
  }

  @override
  Future<bool> isComplete() async => complete;

  @override
  Future<void> markComplete() async => complete = true;
}

void main() {
  late List<http.Request> sent;

  ApiClient clientFor(
    FutureOr<http.Response> Function(http.Request) answer, {
    String token = 'jwt-abc',
  }) {
    sent = [];
    return ApiClient(
      baseUrl: 'https://example.test/api/v1',
      accessToken: () => token,
      client: MockClient((request) async {
        sent.add(request);
        return await answer(request);
      }),
    );
  }

  http.Response json(Object body, [int code = 200]) =>
      http.Response(jsonEncode(body), code,
          headers: const {'content-type': 'application/json'});

  group('the questionnaire before there is an account', () {
    late FakeLocalKyc local;

    setUp(() => local = FakeLocalKyc());

    SyncingKycRepository build({required bool signedIn, ApiClient? api}) =>
        SyncingKycRepository(
          local,
          ApiKycRepository(api ?? clientFor((_) async => json({}))),
          signedIn: () => signedIn,
        );

    test('an answer given while signed out never reaches the server', () async {
      // The bug this fixes: /auth/kyc/ needs a token, so during onboarding
      // every save came back 401 and the app announced the session had
      // expired to somebody who had never signed in.
      final repository = build(signedIn: false);

      await repository.saveAnswers({'concerns': {'stress'}});

      expect(sent, isEmpty);
      expect(local.answers, {'concerns': {'stress'}});
    });

    test('completing it while signed out is recorded on the device', () async {
      final repository = build(signedIn: false);

      await repository.markComplete();

      expect(sent, isEmpty);
      expect(await repository.isComplete(), isTrue);
    });

    test('reads are answered from the device, never the server', () async {
      local.answers = {'goals': {'peace'}};
      final repository = build(signedIn: true);

      expect(await repository.savedAnswers(), {'goals': {'peace'}});
      expect(sent, isEmpty);
    });

    test('an answer given while signed in is sent on as well', () async {
      final repository = build(
        signedIn: true,
        api: clientFor((_) async => json({})),
      );

      await repository.saveAnswers({'concerns': {'anxiety'}});

      expect(sent.single.method, 'PATCH');
      expect(sent.single.url.path, endsWith('/auth/kyc/'));
      expect(
        jsonDecode(sent.single.body)['answers'],
        {'concerns': ['anxiety']},
      );
    });

    test('a server that refuses does not lose the answer', () async {
      final repository = build(
        signedIn: true,
        api: clientFor((_) async => json({'detail': 'nope'}, 500)),
      );

      await repository.saveAnswers({'concerns': {'stress'}});

      // The device is authoritative; the upload is a courtesy.
      expect(local.answers, {'concerns': {'stress'}});
    });
  });

  group('handing the answers to a new account', () {
    test('everything the device holds is written to the account', () async {
      final local = FakeLocalKyc()
        ..answers = {'concerns': {'sleep_disorder'}, 'goals': {'peace'}}
        ..complete = true;
      var signedIn = false;
      final repository = SyncingKycRepository(
        local,
        ApiKycRepository(clientFor((_) async => json({}))),
        signedIn: () => signedIn,
      );

      // Onboarding happened first, with no account.
      await repository.saveAnswers(local.answers);
      expect(sent, isEmpty);

      signedIn = true;
      await repository.uploadToAccount();

      expect(sent.map((r) => r.url.path).toList(), [
        endsWith('/auth/kyc/'),
        endsWith('/auth/kyc/complete/'),
      ]);
    });

    test('nothing is sent when there is still no account', () async {
      final local = FakeLocalKyc()..answers = {'goals': {'clarity'}};
      final repository = SyncingKycRepository(
        local,
        ApiKycRepository(clientFor((_) async => json({}))),
        signedIn: () => false,
      );

      await repository.uploadToAccount();

      expect(sent, isEmpty);
    });

    test('an empty questionnaire sends nothing', () async {
      final repository = SyncingKycRepository(
        FakeLocalKyc(),
        ApiKycRepository(clientFor((_) async => json({}))),
        signedIn: () => true,
      );

      await repository.uploadToAccount();

      expect(sent, isEmpty);
    });
  });

  group('recommendations carry the questionnaire', () {
    test('a guest sends their own answers with the request', () async {
      final local = FakeLocalKyc()
        ..answers = {'concerns': {'sleep_disorder'}, 'gender': {'female'}};
      final api = clientFor((_) async => json([]));

      await ApiContentRepository(api, kyc: local).getRecommendations();

      final request = sent.single;
      expect(request.method, 'POST');
      expect(request.url.path, endsWith('/content/recommendations/'));
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['concerns'], ['sleep_disorder']);
      // Only what says something about what to show. Gender is not that,
      // and a recommendation request is no place to send it.
      expect(body.containsKey('gender'), isFalse);
    });

    test('an unanswered questionnaire sends an empty body', () async {
      final api = clientFor((_) async => json([]));

      await ApiContentRepository(api, kyc: FakeLocalKyc()).getRecommendations();

      expect(jsonDecode(sent.single.body), isEmpty);
    });

    test('unreadable local answers still get a home screen', () async {
      final broken = _BrokenKyc();
      final api = clientFor((_) async => json([]));

      final items =
          await ApiContentRepository(api, kyc: broken).getRecommendations();

      expect(items, isEmpty);
      expect(jsonDecode(sent.single.body), isEmpty);
    });
  });
}

class _BrokenKyc extends FakeLocalKyc {
  @override
  Future<Map<String, Set<String>>> savedAnswers() async =>
      throw const CacheException();
}
