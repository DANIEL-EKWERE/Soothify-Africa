import 'dart:io' show Platform;

import 'package:get/get.dart';

import '../network/api_client.dart';
import '../network/app_api_client.dart';
import 'pref_utils.dart';

import '../../data/repositories/api_auth_repository.dart';
import '../../data/repositories/api_billing_repository.dart';
import '../../data/repositories/api_booking_repository.dart';
import '../../data/repositories/api_breathing_repository.dart';
import '../../data/repositories/api_content_repository.dart';
import '../../data/repositories/api_corporate_repository.dart';
import '../../data/repositories/api_journal_repository.dart';
import '../../data/repositories/api_mood_repository.dart';
import '../../data/repositories/api_expert_application_repository.dart';
import '../../data/repositories/api_kyc_repository.dart';
import '../../data/repositories/api_notification_repository.dart';
import '../../data/repositories/api_profile_repository.dart';
import '../../data/repositories/api_reminder_repository.dart';
import '../../data/repositories/api_spaces_repository.dart';
import '../../data/repositories/api_subscription_repository.dart';
import '../../data/repositories/billing_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/breathing_repository.dart';
import '../../data/repositories/corporate_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/expert_application_repository.dart';
import '../../data/repositories/local_auth_repository.dart';
import '../../data/repositories/local_breathing_repository.dart';
import '../../data/repositories/mock_expert_application_repository.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/repositories/local_journal_repository.dart';
import '../../data/repositories/local_kyc_repository.dart';
import '../../data/repositories/mock_content_repository.dart';
import '../../data/repositories/mock_notification_repository.dart';
import '../../data/repositories/mood_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/kyc_repository.dart';
import '../../data/repositories/local_mood_repository.dart';
import '../../data/repositories/local_profile_repository.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/repositories/mock_community_repository.dart';
import '../../data/repositories/mock_billing_repository.dart';
import '../../data/repositories/mock_booking_repository.dart';
import '../../data/repositories/mock_corporate_repository.dart';
import '../../data/repositories/mock_spaces_repository.dart';
import '../../data/repositories/mock_subscription_repository.dart';
import '../../data/repositories/spaces_repository.dart';
import '../../data/repositories/syncing_journal_repository.dart';
import '../../data/repositories/api_recommendation_repository.dart';
import '../../data/repositories/mock_recommendation_repository.dart';
import '../../data/repositories/mock_reminder_repository.dart';
import '../../data/repositories/recommendation_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../data/repositories/syncing_kyc_repository.dart';
import '../../data/repositories/syncing_breathing_repository.dart';
import '../../data/repositories/syncing_mood_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/subscription_repository.dart';

/// Dependencies available for the whole app lifetime.
///
/// Long-lived services with async setup are registered in main() with
/// putAsync; this binding covers the synchronous ones.
///
/// [MoodRepository] is bound to the local implementation while there is no
/// backend. When the Django API exists, only this line changes.
class InitialBindings extends Bindings {
  /// Whether the screens read from the Django API or from the mocks.
  ///
  /// On by default now that the backend exists. Turn it off for a build that
  /// has to run without a server:
  ///
  ///   flutter run --dart-define=SOOTHIFY_USE_API=false
  static const _useApiBuild = bool.fromEnvironment(
    'SOOTHIFY_USE_API',
    defaultValue: true,
  );

  /// Never in a test, whatever the build says.
  ///
  /// A widget test that reaches this binding would otherwise make real HTTP
  /// calls: slow, flaky, and dependent on a server being up to run the test
  /// suite. A test that wants the API path builds the repository itself with
  /// a MockClient, which is what test/api_repositories_test.dart does.
  static bool get useApi => _useApiBuild && !_inTest;

  static final bool _inTest = Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void dependencies() {
    // main() registers this before runApp, because PushService needs it
    // sooner than this binding runs. Guarded so a test — which reaches this
    // binding without going through main() — still gets one.
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(buildApiClient(), permanent: true);
    }
    // Google and Apple sign-in, behind the same interface the auth
    // controllers take, so a test can hand them a stub instead.
    Get.lazyPut<AuthRepository>(
      () => useApi
          ? ApiAuthRepository(Get.find<ApiClient>())
          : LocalAuthRepository(),
      fenix: true,
    );

    final api = Get.find<ApiClient>();

    // Mood and journal are the device's first and the server's second.
    //
    // What someone records about their own state must survive being
    // offline, so the local store answers every read and takes every write,
    // and the server is told afterwards -- and told again later when the
    // first attempt could not reach it. Reading the server over the top
    // would be the regression: a device offline for a week holds the truth
    // about that week.
    Get.lazyPut<MoodRepository>(
      () => useApi
          ? SyncingMoodRepository(LocalMoodRepository(), ApiMoodRepository(api))
          : LocalMoodRepository(),
      fenix: true,
    );
    // Habit reminders live on the account when there is one: the server
    // sends the push and files the in-app row from a single call, and it
    // cannot be lost the way a local alarm is when Android force-stops
    // the app. A guest keeps a local alarm, which is all they can have.
    Get.lazyPut<ReminderRepository>(
      () => useApi ? ApiReminderRepository(api) : MockReminderRepository(),
      fenix: true,
    );
    Get.lazyPut<RecommendationRepository>(
      () => useApi
          ? ApiRecommendationRepository(api)
          : MockRecommendationRepository(),
      fenix: true,
    );
    Get.lazyPut<JournalRepository>(
      () => useApi
          ? SyncingJournalRepository(
              LocalJournalRepository(),
              ApiJournalRepository(api),
            )
          : LocalJournalRepository(),
      fenix: true,
    );
    // The questionnaire is answered before there is an account to put it
    // on, so the device holds it and the account is told afterwards. Going
    // straight to the API here was what made the age step announce that the
    // session had expired to somebody who had never signed in.
    Get.lazyPut<KycRepository>(
      () => useApi
          ? SyncingKycRepository(
              LocalKycRepository(),
              ApiKycRepository(api),
              signedIn: () => PrefUtils().accessToken.isNotEmpty,
            )
          : LocalKycRepository(),
      fenix: true,
    );

    // The breathing streak, same shape: the minute is finished whether or
    // not the network agrees, and the account is what carries the streak to
    // a new phone. A guest still gets one, on the device alone.
    Get.lazyPut<BreathingRepository>(
      () => useApi
          ? SyncingBreathingRepository(
              LocalBreathingRepository(),
              ApiBreathingRepository(api),
              signedIn: () => PrefUtils().accessToken.isNotEmpty,
            )
          : LocalBreathingRepository(),
      fenix: true,
    );

    if (!useApi) {
      // No backend reachable: the app runs end to end on mocks, which is
      // what makes it demonstrable on a plane and testable without a server.
      Get.lazyPut<ContentRepository>(() => MockContentRepository(), fenix: true);
      Get.lazyPut<ProfileRepository>(() => LocalProfileRepository(), fenix: true);
      Get.lazyPut<SubscriptionRepository>(
        () => MockSubscriptionRepository(),
        fenix: true,
      );
      Get.lazyPut<NotificationRepository>(
        () => MockNotificationRepository(),
        fenix: true,
      );
      Get.lazyPut<BookingRepository>(() => MockBookingRepository(), fenix: true);
      Get.lazyPut<BillingRepository>(() => MockBillingRepository(), fenix: true);
      Get.lazyPut<SpacesRepository>(() => MockSpacesRepository(), fenix: true);
      Get.lazyPut<CorporateRepository>(
        () => MockCorporateRepository(),
        fenix: true,
      );
    } else {
      Get.lazyPut<ContentRepository>(
        // Handed the questionnaire so recommendations can be shaped by it,
        // signed in or not.
        () => ApiContentRepository(api, kyc: Get.find<KycRepository>()),
        fenix: true,
      );
      Get.lazyPut<ProfileRepository>(
        () => ApiProfileRepository(api),
        fenix: true,
      );
      Get.lazyPut<SubscriptionRepository>(
        () => ApiSubscriptionRepository(api),
        fenix: true,
      );
      Get.lazyPut<NotificationRepository>(
        () => ApiNotificationRepository(api),
        fenix: true,
      );
      Get.lazyPut<BookingRepository>(
        () => ApiBookingRepository(api),
        fenix: true,
      );
      Get.lazyPut<BillingRepository>(
        () => ApiBillingRepository(api),
        fenix: true,
      );
      Get.lazyPut<SpacesRepository>(() => ApiSpacesRepository(api), fenix: true);
      Get.lazyPut<CorporateRepository>(
        () => ApiCorporateRepository(api),
        fenix: true,
      );
    }

    // Applying to practise here. Bound app-wide rather than per route
    // because the intro reads "is yours still being looked at?" before the
    // form is opened.
    Get.lazyPut<ExpertApplicationRepository>(
      () => useApi
          ? ApiExpertApplicationRepository(api)
          : MockExpertApplicationRepository(),
      fenix: true,
    );

    // The forum is on hold server-side (FEATURES['community'] in the Django
    // settings), so it stays on the mock until those endpoints are mounted.
    Get.lazyPut<CommunityRepository>(
      () => MockCommunityRepository(),
      fenix: true,
    );
  }
}
