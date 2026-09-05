import 'package:get/get.dart';

import '../modules/auth/intro/binding/intro_binding.dart';
import '../modules/auth/language/binding/language_binding.dart';
import '../modules/auth/language/language_screen.dart';
import '../modules/auth/personalize/binding/personalize_binding.dart';
import '../modules/auth/personalize/personalize_screen.dart';
import '../modules/auth/intro/intro_screen.dart';
import '../modules/auth/signin/binding/signin_binding.dart';
import '../modules/auth/signin/signin_screen.dart';
import '../modules/auth/signup/binding/signup_binding.dart';
import '../modules/auth/signup/signup_screen.dart';
import '../modules/auth/kyc/binding/kyc_binding.dart';
import '../modules/auth/kyc/kyc_screen.dart';
import '../modules/auth/role_select/binding/role_select_binding.dart';
import '../modules/auth/role_select/role_select_screen.dart';
import '../modules/auth/splash/splash_screen.dart';
import '../modules/practitioner/dashboard/binding/practitioner_dashboard_binding.dart';
import '../modules/practitioner/dashboard/practitioner_dashboard_screen.dart';
import '../modules/user/mood_checker/binding/mood_checker_binding.dart';
import '../modules/user/journal/binding/journal_binding.dart';
import '../modules/user/journal/controller/journal_compose_controller.dart';
import '../modules/user/journal/journal_compose_screen.dart';
import '../modules/user/journal/journal_screen.dart';
import '../modules/user/recommendation/binding/recommendation_binding.dart';
import '../modules/user/recommendation/recommendation_screen.dart';
import '../modules/user/community/compose/binding/compose_binding.dart';
import '../modules/user/community/compose/compose_screen.dart';
import '../modules/user/community/forum/binding/forum_binding.dart';
import '../modules/user/community/forum/forum_screen.dart';
import '../modules/user/community/thread/binding/thread_binding.dart';
import '../modules/user/community/thread/thread_screen.dart';
import '../modules/user/booking/binding/booking_binding.dart';
import '../modules/user/booking/booking_screen.dart';
import '../modules/user/checkin/binding/checkin_binding.dart';
import '../modules/user/checkin/checkin_screen.dart';
import '../modules/user/library/binding/library_binding.dart';
import '../modules/user/shelf/binding/shelf_binding.dart';
import '../modules/user/shelf/shelf_screen.dart';
import '../modules/user/wellness_kyc/binding/wellness_kyc_binding.dart';
import '../modules/user/wellness_kyc/wellness_kyc_screen.dart';
import '../modules/user/library/library_screen.dart';
import '../modules/user/schedule/binding/schedule_binding.dart';
import '../modules/user/schedule/schedule_screen.dart';
import '../modules/user/settings/binding/settings_binding.dart';
import '../modules/user/settings/settings_screen.dart';
import '../modules/user/shell/binding/shell_binding.dart';
import '../modules/user/shell/shell_screen.dart';
import '../modules/user/mood_record/binding/mood_record_binding.dart';
import '../modules/user/mood_record/mood_record_screen.dart';
import '../modules/user/mood_checker/mood_checker_screen.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.intro,
      page: () => const IntroScreen(),
      binding: IntroBinding(),
    ),
    GetPage(
      name: AppRoutes.personalize,
      page: () => const PersonalizeScreen(),
      binding: PersonalizeBinding(),
    ),
    GetPage(
      name: AppRoutes.language,
      page: () => const LanguageScreen(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.signin,
      page: () => const SigninScreen(),
      binding: SigninBinding(),
    ),
    GetPage(
      name: AppRoutes.roleSelect,
      page: () => const RoleSelectScreen(),
      binding: RoleSelectBinding(),
    ),
    GetPage(
      name: AppRoutes.kyc,
      page: () => const KycScreen(),
      binding: KycBinding(),
    ),
    GetPage(
      name: AppRoutes.shell,
      page: () => const ShellScreen(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: AppRoutes.journalCompose,
      page: () => const JournalComposeScreen(),
      binding: BindingsBuilder.put(JournalComposeController.new),
    ),
    GetPage(
      name: AppRoutes.journal,
      page: () => const JournalScreen(),
      binding: JournalBinding(),
    ),
    GetPage(
      name: AppRoutes.recommendation,
      page: () => const RecommendationScreen(),
      binding: RecommendationBinding(),
    ),
    GetPage(
      name: AppRoutes.communityForum,
      page: () => const ForumScreen(),
      binding: ForumBinding(),
    ),
    GetPage(
      name: AppRoutes.communityCompose,
      page: () => const ComposeScreen(),
      binding: ComposeBinding(),
    ),
    GetPage(
      name: AppRoutes.communityThread,
      page: () => const ThreadScreen(),
      binding: ThreadBinding(),
    ),
    GetPage(
      name: AppRoutes.library,
      page: () => const LibraryScreen(),
      binding: LibraryBinding(),
    ),
    GetPage(
      name: AppRoutes.wellnessKyc,
      page: () => const WellnessKycScreen(),
      binding: WellnessKycBinding(),
    ),
    GetPage(
      name: AppRoutes.booking,
      page: () => const BookingScreen(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.shelf,
      page: () => const ShelfScreen(),
      binding: ShelfBinding(),
    ),
    GetPage(
      name: AppRoutes.schedule,
      page: () => const ScheduleScreen(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: AppRoutes.checkin,
      page: () => const CheckinScreen(),
      binding: CheckinBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.moodChecker,
      page: () => const MoodCheckerScreen(),
      binding: MoodCheckerBinding(),
    ),
    GetPage(
      name: AppRoutes.moodRecord,
      page: () => const MoodRecordScreen(),
      binding: MoodRecordBinding(),
    ),
    GetPage(
      name: AppRoutes.practitionerDashboard,
      page: () => const PractitionerDashboardScreen(),
      binding: PractitionerDashboardBinding(),
    ),
  ];
}
