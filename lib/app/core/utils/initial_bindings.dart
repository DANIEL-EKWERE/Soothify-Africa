import 'package:get/get.dart';

import '../../data/repositories/content_repository.dart';
import '../../data/repositories/local_kyc_repository.dart';
import '../../data/repositories/mock_content_repository.dart';
import '../../data/repositories/mood_repository.dart';
import '../../data/repositories/kyc_repository.dart';
import '../../data/repositories/local_mood_repository.dart';
import '../../data/repositories/local_profile_repository.dart';
import '../../data/repositories/community_repository.dart';
import '../../data/repositories/mock_community_repository.dart';
import '../../data/repositories/mock_subscription_repository.dart';
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
  @override
  void dependencies() {
    Get.lazyPut<MoodRepository>(() => LocalMoodRepository(), fenix: true);
    // Backs the Home screen's Recommended list and Popular Articles. Still
    // the mock while there is no backend — swapping in the Django-backed
    // implementation is this one line.
    Get.lazyPut<ContentRepository>(() => MockContentRepository(), fenix: true);
    Get.lazyPut<KycRepository>(
      () => LocalKycRepository(),
      fenix: true,
    );
    Get.lazyPut<ProfileRepository>(
      () => LocalProfileRepository(),
      fenix: true,
    );
    Get.lazyPut<CommunityRepository>(
      () => MockCommunityRepository(),
      fenix: true,
    );
    Get.lazyPut<SubscriptionRepository>(
      () => MockSubscriptionRepository(),
      fenix: true,
    );
  }
}
