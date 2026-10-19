import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/network/api_client.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/expert_recommendation.dart';
import 'package:soothifyafrica/app/data/repositories/api_recommendation_repository.dart';
import 'package:soothifyafrica/app/data/repositories/local_journal_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_recommendation_repository.dart';
import 'package:soothifyafrica/app/data/repositories/recommendation_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/user/journal/controller/journal_controller.dart';

/// What practitioners recommend, as the Journal's second tab reads it.
///
/// These rows used to be [ExpertRecommendation.sample] — the frame's own
/// three, hardcoded, identical for everybody.

Map<String, dynamic> card({
  int id = 7,
  bool isNew = true,
  String title = 'Guided Breathing for calm',
}) =>
    {
      'id': id,
      'expert_name': 'Dr. Amara Okafor',
      'expert_avatar_url': 'https://example.test/a.jpg',
      'session_label': 'Therapy',
      'note': 'Try this before bed.',
      'is_new': isNew,
      'created_at': '2026-10-19T09:41:00Z',
      'content': {
        'id': 12,
        'title': title,
        'media_type': 'video',
        'duration_seconds': 300,
        'tag': 'Mindfulness & Stress Relief',
        'cover_url': 'https://example.test/cover.jpg',
      },
    };

void main() {
  late List<http.Request> sent;

  ApiClient clientAnswering(Object Function(http.Request) answer) {
    sent = [];
    return ApiClient(
      baseUrl: 'https://example.test/api/v1',
      accessToken: () => 'jwt-abc',
      client: MockClient((request) async {
        sent.add(request);
        return http.Response(jsonEncode(answer(request)), 200,
            headers: const {'content-type': 'application/json'});
      }),
    );
  }

  group('reading what the server sent', () {
    test('a card carries the expert, the note and the content', () async {
      final api = clientAnswering((_) => [card()]);

      final rows = await ApiRecommendationRepository(api).mine();

      expect(sent.single.url.path, endsWith('/recommendations/'));
      final row = rows.single;
      expect(row.expertName, 'Dr. Amara Okafor');
      expect(row.sessionLabel, 'Therapy');
      expect(row.note, 'Try this before bed.');
      expect(row.isNew, isTrue);
      expect(row.avatar, 'https://example.test/a.jpg');
    });

    test('the content names what it is and what to do with it', () async {
      final api = clientAnswering((_) => [card()]);

      final content = (await ApiRecommendationRepository(api).mine()).single.content;

      expect(content.id, '12');
      expect(content.kind, ExpertContentKind.video);
      expect(content.kind.action, 'Watch video');
      // "5 min Mindfulness & Stress Relief" — built here, not sent.
      expect(content.meta, '5 min Mindfulness & Stress Relief');
      expect(content.cover, 'https://example.test/cover.jpg');
    });

    test('an article has no length worth printing', () async {
      final api = clientAnswering((_) => [
            card()
              ..['content'] = {
                'id': 3,
                'title': 'Why sleep slips',
                'media_type': 'article',
                'duration_seconds': 0,
                'tag': 'Sleep',
              },
          ]);

      final content = (await ApiRecommendationRepository(api).mine()).single.content;

      expect(content.meta, 'Sleep');
      expect(content.kind.action, 'Read Article');
    });

    test('marking one read posts to its own address', () async {
      final api = clientAnswering((_) => card(isNew: false));

      final row = await ApiRecommendationRepository(api).markRead('7');

      expect(sent.single.method, 'POST');
      expect(sent.single.url.path, endsWith('/recommendations/7/read/'));
      expect(row.isNew, isFalse);
    });
  });

  group('the Journal tab', () {
    late SessionService session;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      PrefUtils.resetForTesting();
      await PrefUtils().init();
      session = await SessionService().init();
      Get.put<SessionService>(session);
    });

    tearDown(Get.reset);

    JournalController build(RecommendationRepository? store) =>
        JournalController(LocalJournalRepository(), recommendations: store);

    test('a guest is shown none, and none are asked for', () async {
      final store = _Counting();

      final c = build(store);
      await c.load();

      expect(store.calls, 0);
      expect(c.recommendations, isEmpty);
    });

    test('somebody signed in gets what was left for them', () async {
      await PrefUtils().setTokens(access: 'jwt-abc', refresh: 'r');
      final store = _Counting();

      final c = build(store);
      await c.load();

      expect(store.calls, 1);
      expect(c.recommendations.single.expertName, 'Dr. Amara Okafor');
      // The frame's three samples are gone.
      expect(c.recommendations.length, 1);
    });

    test('a server that will not answer leaves the journal standing', () async {
      await PrefUtils().setTokens(access: 'jwt-abc', refresh: 'r');

      final c = build(_Failing());
      await c.load();

      // The other half of this screen is the client's own writing. Taking
      // it down over the second tab would be the wrong trade.
      expect(c.entries, isEmpty);
      expect(c.isLoading.value, isFalse);
    });

    test('the unread count is what the server says', () async {
      await PrefUtils().setTokens(access: 'jwt-abc', refresh: 'r');

      final c = build(_Counting());
      await c.load();

      expect(c.unread, 1);
    });
  });

  group('without a server', () {
    test('the mock still marks one read', () async {
      final store = MockRecommendationRepository();
      final first = (await store.mine()).first;

      final read = await store.markRead(first.id);

      expect(read.isNew, isFalse);
      expect((await store.mine()).first.isNew, isFalse);
    });
  });
}

class _Counting implements RecommendationRepository {
  int calls = 0;

  @override
  Future<List<ExpertRecommendation>> mine() async {
    calls += 1;
    return [ExpertRecommendation.fromJson(card())];
  }

  @override
  Future<ExpertRecommendation> markRead(String id) async =>
      ExpertRecommendation.fromJson(card(isNew: false));
}

class _Failing implements RecommendationRepository {
  @override
  Future<List<ExpertRecommendation>> mine() async => throw Exception('down');

  @override
  Future<ExpertRecommendation> markRead(String id) async =>
      throw Exception('down');
}
