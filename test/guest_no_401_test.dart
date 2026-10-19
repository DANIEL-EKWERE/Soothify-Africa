import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soothifyafrica/app/core/errors/app_exception.dart';
import 'package:soothifyafrica/app/core/utils/pref_utils.dart';
import 'package:soothifyafrica/app/data/models/media_item.dart';
import 'package:soothifyafrica/app/data/models/plan_tier.dart';
import 'package:soothifyafrica/app/data/models/profile_stats.dart';
import 'package:soothifyafrica/app/data/models/subscription_plan.dart';
import 'package:soothifyafrica/app/data/models/user_profile.dart';
import 'package:soothifyafrica/app/data/repositories/content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/mock_content_repository.dart';
import 'package:soothifyafrica/app/data/repositories/profile_repository.dart';
import 'package:soothifyafrica/app/data/repositories/subscription_repository.dart';
import 'package:soothifyafrica/app/data/services/session_service.dart';
import 'package:soothifyafrica/app/modules/user/discovery/controller/discovery_tab_controller.dart';
import 'package:soothifyafrica/app/modules/user/profile/controller/profile_tab_controller.dart';

/// What a guest's Home must not do.
///
/// Three endpoints are about a particular person — their stats, their
/// profile, what they played last — so they need a bearer token and answer
/// 401 without one. Called as a guest they produced three "Your session has
/// expired. Please sign in again." popups on a first run, to somebody who
/// had never signed in.
///
/// A role is chosen during onboarding, before any account exists, so
/// `isSignedIn` is already true by then. The test below pins the thing that
/// actually distinguishes them.

class _CountingContent extends MockContentRepository {
  int recentCalls = 0;

  @override
  Future<List<MediaItem>> getRecent() {
    recentCalls += 1;
    throw const UnauthorizedException();
  }

  @override
  Future<List<MediaItem>> getByCategory(String id) async => const [];
}

class _CountingProfiles implements ProfileRepository {
  int statsCalls = 0;

  @override
  Future<ProfileStats> getStats() {
    statsCalls += 1;
    throw const UnauthorizedException();
  }

  @override
  Future<UserProfile> me() async => const UserProfile(id: '1');

  @override
  Future<UserProfile> update({
    String? fullName,
    String? language,
    String? moodFigure,
    String? communityHandle,
  }) async =>
      me();

  @override
  Future<UserProfile> uploadAvatar(String filePath) async => me();
}

class _Plans implements SubscriptionRepository {
  @override
  Future<List<SubscriptionPlan>> getPlans() async => const [];

  @override
  Future<List<PlanTier>> getTiers(BillingPeriod period) async => const [];
}

void main() {
  late SessionService session;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefUtils.resetForTesting();
    await PrefUtils().init();
    session = await SessionService().init();
    Get.put<SessionService>(session);
  });

  tearDown(Get.reset);

  group('a guest', () {
    test('has no account even once a role is chosen', () async {
      // The trap: onboarding sets a role before anybody has registered.
      expect(session.hasAccount, isFalse);
      expect(session.isSignedIn, isFalse);
    });

    test('the discovery tab does not ask what they played last', () async {
      final content = _CountingContent();
      Get.put<ContentRepository>(content);

      await DiscoveryTabController(content, _Plans(), session: session).load();

      expect(content.recentCalls, 0);
    });

    test('the profile tab does not ask for their counters', () async {
      final profiles = _CountingProfiles();

      await ProfileTabController(profiles, session).load();

      expect(profiles.statsCalls, 0);
      expect(ProfileTabController(profiles, session).stats.value,
          ProfileStats.empty);
    });
  });

  group('somebody signed in', () {
    setUp(() async {
      await PrefUtils().setTokens(access: 'jwt-abc', refresh: 'r');
    });

    test('is asked about, token in hand', () async {
      expect(session.hasAccount, isTrue);

      final content = _CountingContent();
      Get.put<ContentRepository>(content);
      await DiscoveryTabController(content, _Plans(), session: session).load();

      expect(content.recentCalls, 1);
    });
  });
}
