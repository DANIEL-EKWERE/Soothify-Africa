import 'package:get/get.dart';

import '../data/models/journal_entry.dart';
import '../modules/practitioner/availability/controller/slot_editor_controller.dart';
import '../modules/practitioner/call/controller/joining_session_controller.dart';
import '../modules/practitioner/call/joining_session_screen.dart';
import '../modules/practitioner/availability/expert_availability_screen.dart';
import '../modules/practitioner/availability/expert_slot_editor_screen.dart';
import '../modules/practitioner/dashboard/controller/expert_dashboard_controller.dart';
import '../modules/practitioner/notes/controller/session_notes_controller.dart';
import '../modules/practitioner/notes/session_notes_screen.dart';
import '../modules/practitioner/payouts/binding/payout_binding.dart';
import '../modules/practitioner/payouts/expert_payout_method_screen.dart';
import '../modules/practitioner/payouts/expert_payouts_screen.dart';
import '../modules/practitioner/payouts/expert_withdraw_screen.dart';
import '../modules/practitioner/shell/binding/expert_shell_binding.dart';
import '../modules/practitioner/shell/expert_shell_screen.dart';
import '../modules/user/article/article_screen.dart';
import '../modules/user/corporate/binding/corporate_binding.dart';
import '../modules/user/settings/account_settings_screen.dart';
import '../modules/user/settings/controller/notification_settings_controller.dart';
import '../modules/user/settings/delete_account_screen.dart';
import '../modules/user/subscription_manage/billing_history_screen.dart';
import '../modules/user/subscription_manage/binding/subscription_manage_binding.dart';
import '../modules/user/subscription_manage/change_plan_screen.dart';
import '../modules/user/subscription_manage/your_subscription_screen.dart';
import '../modules/user/settings/notification_settings_screen.dart';
import '../modules/user/settings/policy_screen.dart';
import '../modules/user/settings/update_account_screen.dart';
import '../modules/user/settings/user_profile_screen.dart';
import '../modules/user/corporate/corporate_form_screen.dart';
import '../modules/user/corporate/corporate_success_screen.dart';
import '../modules/user/booking_calendar/binding/booking_calendar_binding.dart';
import '../modules/user/booking_calendar/booking_calendar_screen.dart';
import '../modules/user/booking_calendar/booking_confirmed_screen.dart';
import '../modules/user/breathe/binding/breathe_binding.dart';
import '../modules/user/breathe/breathe_screen.dart';
import '../modules/user/trial_offer/binding/trial_offer_binding.dart';
import '../modules/user/trial_offer/trial_offer_screen.dart';
import '../modules/user/trial_offer/trial_payment_screen.dart';
import '../modules/user/expert_application/binding/expert_application_binding.dart';
import '../modules/user/expert_application/expert_application_screen.dart';
import '../modules/user/expert_application/expert_intro_screen.dart';
import '../modules/user/journal/controller/expert_recommendation_controller.dart';
import '../modules/user/journal/expert_recommendation_screen.dart';
import '../modules/user/article/binding/article_binding.dart';
import '../modules/user/payment/binding/booking_payment_binding.dart';
import '../modules/user/payment/booking_payment_screen.dart';
import '../modules/user/payment/care_guarantee_screen.dart';
import '../modules/user/payment/payment_success_screen.dart';
import '../modules/user/videos/binding/videos_binding.dart';
import '../modules/user/videos/videos_screen.dart';
import '../data/repositories/journal_repository.dart';

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
import '../modules/user/payment/cancellation_policy_screen.dart';
import '../modules/user/session/binding/client_joining_binding.dart';
import '../modules/user/session/client_joining_screen.dart';
import '../modules/user/spaces/binding/spaces_binding.dart';
import '../modules/user/spaces/spaces_screen.dart';
import '../modules/user/spaces/studio_profile_screen.dart';
import '../modules/user/book_expert/binding/book_expert_binding.dart';
import '../modules/user/book_expert/book_expert_screen.dart';
import '../modules/user/booking/booking_screen.dart';
import '../modules/user/checkin/binding/checkin_binding.dart';
import '../modules/user/daily/binding/daily_binding.dart';
import '../modules/user/daily/daily_screen.dart';
import '../modules/user/daily/daily_start_screen.dart';
import '../modules/user/daily/reminder_screen.dart';
import '../modules/user/checkin/checkin_screen.dart';
import '../modules/user/ai_hub/ai_hub_screen.dart';
import '../modules/user/notifications/binding/notifications_binding.dart';
import '../modules/user/notifications/notifications_screen.dart';
import '../modules/user/ai_hub/binding/ai_hub_binding.dart';
import '../modules/user/filters/binding/filters_binding.dart';
import '../modules/user/filters/filters_screen.dart';
import '../../app/data/models/media_filter.dart';
import '../modules/user/library/binding/library_binding.dart';
import '../modules/user/media/binding/media_binding.dart';
import '../modules/user/media/media_screen.dart';
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
import '../modules/user/mood_recommendation/binding/mood_recommendation_binding.dart';
import '../modules/user/mood_recommendation/mood_recommendation_screen.dart';
import '../modules/user/mood_record/binding/mood_record_binding.dart';
import '../modules/user/mood_record/mood_record_screen.dart';
import '../modules/user/mood_checker/mood_checker_screen.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
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
      // Takes the entry to re-open, when the list's chevron supplied one.
      binding: BindingsBuilder(() {
        Get.put(
          JournalComposeController(
            Get.find<JournalRepository>(),
            entry: Get.arguments is JournalEntry
                ? Get.arguments as JournalEntry
                : null,
          ),
        );
      }),
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
      name: AppRoutes.clientJoining,
      page: () => const ClientJoiningScreen(),
      binding: ClientJoiningBinding(),
    ),
    GetPage(
      name: AppRoutes.spaces,
      page: () => const SpacesScreen(),
      binding: SpacesBinding(),
    ),
    GetPage(
      name: AppRoutes.studioProfile,
      page: () => const StudioProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.cancellationPolicy,
      page: () => const CancellationPolicyScreen(),
    ),
    GetPage(
      name: AppRoutes.bookExpert,
      page: () => const BookExpertScreen(),
      binding: BookExpertBinding(),
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
      name: AppRoutes.media,
      page: () => const MediaScreen(),
      binding: MediaBinding(),
    ),
    // Three routes, one screen: the sheets differ only in their body, and
    // FiltersBinding creates the shared controller on whichever is entered
    // first.
    // Both push over the expert shell and read its controller. The binding
    // is repeated so a deep link straight to either still resolves it.
    // The payout trio shares one controller: the amount chosen on the first
    // has to survive into the second.
    GetPage(
      name: AppRoutes.expertWithdraw,
      page: () => const ExpertWithdrawScreen(),
      bindings: [ExpertShellBinding(), PayoutBinding()],
    ),
    GetPage(
      name: AppRoutes.expertPayoutMethod,
      page: () => const ExpertPayoutMethodScreen(),
      bindings: [ExpertShellBinding(), PayoutBinding()],
    ),
    GetPage(
      name: AppRoutes.expertPayouts,
      page: () => const ExpertPayoutsScreen(),
      bindings: [ExpertShellBinding(), PayoutBinding()],
    ),
    GetPage(
      name: AppRoutes.expertAvailability,
      page: () => const ExpertAvailabilityScreen(),
      binding: ExpertShellBinding(),
    ),
    GetPage(
      name: AppRoutes.expertJoinSession,
      page: () => const JoiningSessionScreen(),
      binding: BindingsBuilder.put(JoiningSessionController.new),
    ),
    GetPage(
      name: AppRoutes.expertSlotEditor,
      page: () => const ExpertSlotEditorScreen(),
      bindings: [
        ExpertShellBinding(),
        BindingsBuilder(() {
          Get.put(
            SlotEditorController(Get.find<ExpertDashboardController>()),
          );
        }),
      ],
    ),
    GetPage(
      name: AppRoutes.expertSessionNotes,
      page: () => const SessionNotesScreen(),
      bindings: [
        ExpertShellBinding(),
        BindingsBuilder.put(SessionNotesController.new),
      ],
    ),
    GetPage(
      name: AppRoutes.expertApplication,
      page: () => const ExpertIntroScreen(),
      binding: ExpertApplicationBinding(),
    ),
    GetPage(
      name: AppRoutes.expertApplicationForm,
      page: () => const ExpertApplicationScreen(),
      binding: ExpertApplicationBinding(),
    ),
    GetPage(
      name: AppRoutes.journalRecommendation,
      page: () => const ExpertRecommendationScreen(),
      binding: BindingsBuilder.put(ExpertRecommendationController.new),
    ),
    GetPage(
      name: AppRoutes.manageSubscription,
      page: () => const YourSubscriptionScreen(),
      binding: SubscriptionManageBinding(),
    ),
    GetPage(
      name: AppRoutes.changePlan,
      page: () => const ChangePlanScreen(),
      binding: SubscriptionManageBinding(),
    ),
    GetPage(
      name: AppRoutes.billingHistory,
      page: () => const BillingHistoryScreen(),
      binding: SubscriptionManageBinding(),
    ),
    GetPage(
      name: AppRoutes.accountSettings,
      page: () => const AccountSettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.updateAccount,
      page: () => const UpdateAccountScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.userProfile,
      page: () => const UserProfileScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.deleteAccount,
      page: () => const DeleteAccountScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.notificationSettings,
      page: () => const NotificationSettingsScreen(),
      binding: BindingsBuilder.put(NotificationSettingsController.new),
    ),
    GetPage(
      name: AppRoutes.policy,
      page: () => const PolicyScreen(),
    ),
    GetPage(
      name: AppRoutes.corporateForm,
      page: () => const CorporateFormScreen(),
      binding: CorporateBinding(),
    ),
    GetPage(
      name: AppRoutes.corporateSuccess,
      page: () => const CorporateSuccessScreen(),
      binding: CorporateBinding(),
    ),
    GetPage(
      name: AppRoutes.subscriptionOffer,
      page: () => const TrialOfferScreen(),
      binding: TrialOfferBinding(),
    ),
    GetPage(
      name: AppRoutes.breathe,
      page: () => const BreatheScreen(),
      binding: BreatheBinding(),
    ),
    GetPage(
      name: AppRoutes.trialPayment,
      page: () => const TrialPaymentScreen(),
      binding: TrialOfferBinding(),
    ),
    GetPage(
      name: AppRoutes.article,
      page: () => const ArticleScreen(),
      binding: ArticleBinding(),
    ),
    GetPage(
      name: AppRoutes.videos,
      page: () => const VideosScreen(),
      binding: VideosBinding(),
    ),
    // Payment, then its receipt. Two routes rather than two stages of one,
    // because the receipt must not be walked back into an unpaid form.
    GetPage(
      name: AppRoutes.bookingPayment,
      page: () => const BookingPaymentScreen(),
      binding: BookingPaymentBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingCalendar,
      page: () => const BookingCalendarScreen(),
      binding: BookingCalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.bookingConfirmed,
      page: () => const BookingConfirmedScreen(),
    ),
    GetPage(
      name: AppRoutes.confirmBooking,
      page: () => const CareGuaranteeScreen(),
      binding: BookingPaymentBinding(),
    ),
    GetPage(
      name: AppRoutes.paymentSuccess,
      page: () => const PaymentSuccessScreen(),
      binding: BookingPaymentBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationsBinding(),
    ),
    // The hub is summoned by a floating button rather than reached by going
    // deeper, so it rises instead of sliding across.
    GetPage(
      name: AppRoutes.aiHub,
      page: () => const AiHubScreen(),
      binding: AiHubBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.filterDuration,
      page: () => const FiltersScreen(kind: FilterKind.duration),
      binding: FiltersBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.filterMore,
      page: () => const FiltersScreen(kind: FilterKind.more),
      binding: FiltersBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.filterStyle,
      page: () => const FiltersScreen(kind: FilterKind.style),
      binding: FiltersBinding(),
      transition: Transition.downToUp,
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
      name: AppRoutes.daily,
      page: () => const DailyScreen(),
      binding: DailyBinding(),
    ),
    GetPage(
      name: AppRoutes.dailyStart,
      page: () => const DailyStartScreen(),
      binding: DailyBinding(),
    ),
    GetPage(
      name: AppRoutes.dailyReminder,
      page: () => const ReminderScreen(),
      binding: DailyBinding(),
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
      name: AppRoutes.moodRecommendation,
      page: () => const MoodRecommendationScreen(),
      binding: MoodRecommendationBinding(),
    ),
    // A celebration, not a destination: it fades up rather than sliding.
    GetPage(
      name: AppRoutes.moodRecord,
      transition: Transition.fadeIn,
      page: () => const MoodRecordScreen(),
      binding: MoodRecordBinding(),
    ),
    GetPage(
      name: AppRoutes.practitionerDashboard,
      page: () => const ExpertShellScreen(),
      binding: ExpertShellBinding(),
    ),
  ];
}
