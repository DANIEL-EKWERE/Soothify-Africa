/// Nigerian Pidgin (`pcm`).
///
/// Written as it is spoken in Lagos and Abuja, not as English with the
/// grammar bent: "How you dey?" rather than "How are you dey?". Where a
/// word has no settled Pidgin form — "Passport", a plan's name, a brand —
/// it stays as it is, because translating a product name into something
/// nobody says is worse than leaving it.
///
/// A key missing here falls back to English, which is why this file may
/// trail [en] without anything breaking.
const Map<String, String> pcm = {
  // ------------------------------------------------------------ language
  'language.title': 'Which language you wan yarn?',
  'language.subtitle': 'Pick di language wey you sabi pass.',
  'language.continue': 'Continue',

  // ---------------------------------------------------------------- nav
  'nav.home': 'Home',
  'nav.plans': 'Plans',
  'nav.discovery': 'Discover',
  'nav.community': 'Community',
  'nav.profile': 'Profile',
  'nav.schedule': 'Schedule',
  'nav.earnings': 'Money',
  'nav.notes': 'Notes',

  // --------------------------------------------------------------- home
  'home.greetingMorning': 'Good morning',
  'home.greetingAfternoon': 'Good afternoon',
  'home.greetingEvening': 'Good evening',
  'home.howAreYou': 'How you dey today?',
  'home.explore': 'Check Am',
  'home.recommended': 'Wetin we pick for you',
  'home.popular': 'Wetin Plenty People Dey Watch',
  'home.seeAll': 'See All',
  'home.seeMore': 'See more',
  'home.moodChecker': 'Mood Checker',
  'home.moodCheckerBody':
      'Take small time check yourself, make you sabi how you really dey '
      'feel.',

  // -------------------------------------------------------------- common
  'common.cancel': 'Cancel',
  'common.save': 'Save',
  'common.continue': 'Continue',
  'common.retry': 'Try Again',
  'common.back': 'Go Back',
  'common.next': 'Next',
  'common.done': 'Done',

  // --------------------------------------------------------------- plans
  'plans.title': 'Plans',
  'plans.monthly': 'Every Month',
  'plans.annual': 'Every Year',
  'plans.startTrial': 'Start 7-Day Free Trial',
  'plans.chooseTier': 'Pick Your Level',
  'plans.corporate': 'Talk to Corporate Team',

  // -------------------------------------------------------------- expert
  'expert.welcomeBack': 'Welcome back,',
  'expert.difference': 'You dey really make difference.',
  'expert.upcomingSessions': 'Sessions Wey Dey Come',
  'expert.joinCall': 'Join call',
  'expert.quickActions': 'Quick Things',
  'expert.earningsTitle': 'Money',
  'expert.availableEarnings': 'Money Wey Ready',
  'expert.withdraw': 'Comot Money',

  // ------------------------------------------------------------- partner
  'partner.dashboard': 'Soothify Partner Dashboard',
  'partner.overview': 'Overview',
  'partner.guestList': 'Guest List',
  'partner.pendingBookings': 'Booking Wey Dey Wait',
  'partner.confirmedToday': 'Confirm Today',
  'partner.monthlyPayout': 'Money Wey Gather Dis Month',
  'partner.realTime': 'Notification As E Dey Happen',
  'partner.todaysGuests': 'Today Guests',
  'partner.checkedIn': 'Don Enter',
  'partner.awaitingArrival': 'Still Dey Come',
  'partner.scanQr': 'Scan Passport QR Code',
  'partner.verifyCode': 'Check Entry Code',

  // ----------------------------------- expert: profile, notes and earnings
  'expert.profileBody':
      'Your availability, session notes and money dey on dem own '
      'tabs.',
  'expert.settings': 'Settings',
  'expert.switchRole': 'Change role',
  'expert.sessionNotes': 'Session notes',
  'expert.notesBlurb':
      'Dey follow up your sessions and how your client dey '
      'progress, di main things and wetin suppose happen next.',
  'expert.recentPayouts': 'Money Wey Dem Send Recently',
  'common.seeAll': 'See All',
  'expert.bankCharge': 'Bank go collect 10% as service charge.',
  'expert.nextPayout': 'Next payment wey go enter by itself',
  'expert.payoutMethod': 'How dem go pay you',
  'expert.notSet': 'You no set am',
  'expert.thisWeek': 'Dis week',
  'expert.totalEarned': 'All di money you don make',

  // ---------------------------------------- expert: dashboard and schedule
  'expert.totalThisWeek': 'All di money you make dis week',
  'expert.nothingBooked': 'Nobody book yet.',
  'expert.updateAvailability': 'Change When You Free',
  'expert.updateAvailabilityBody': 'Set di days and times wey you free.',
  'expert.addSessionNotes': 'Add Session Notes',
  'expert.addSessionNotesBody':
      'Dey follow up your sessions and how your client dey do.',
  'expert.upcomingSession': 'Session Wey Dey Come',

  // ---------------------------------- expert: session notes and withdrawal
  'expert.howDidItGo': 'How di session go',
  'expert.sessionSummary': 'Wetin Happen For Di Session',
  'expert.recommendation': 'Wetin You Advise',
  'expert.notesHint':
      'How di session go? Write about how your client dey '
      'progress, di main things wey una talk, wetin you notice or '
      'wetin go happen next.',
  'expert.saving': 'E dey save…',
  'expert.sendSomething': 'Send dem something wey dem go use practice',
  'expert.withdrawal': 'Comot Money',
  'expert.withdrawHowMuch': 'How much you wan comot',
  'expert.destination': 'Where di money go enter',
  'expert.addPayoutAccount': '+  Add account wey dem go pay',

  // ----------------------- expert: payout method, bank details and outcome
  'expert.payoutMethodHeading': 'How Dem Go Pay You',
  'expert.payoutMethodBody':
      'Na here your money go enter. You can change di details '
      'anytime.',
  'expert.addNewPayoutMethod': '+  Add New Way Dem Go Pay You',
  'expert.backToEarnings': 'Go Back To Money',
  'expert.bankTransferNgn': 'Bank Transfer (NGN)',
  'expert.active': 'E Dey Work',
  'expert.chooseMethodBody': 'Pick how you want make Soothify pay you.',
  'common.proceed': 'Continue',
  'expert.paystackNote': 'Paystack dey handle all payment safe safe.',
  'expert.bankDetailsTitle': 'Bank Transfer Details',
  'expert.bankDetailsBody':
      'Put your bank account details so dem go pay you in Naira '
      '(NGN)',
  'expert.bankName': 'Name of Bank',
  'expert.accountNumber': 'Account Number',
  'expert.accountName': 'Account Name',
  'expert.addBankDetails': 'Add Bank Details',
  'expert.selectBank': 'Pick Bank',
  'expert.paymentMethod': 'How Dem Go Pay',
  'expert.noPayouts': 'Dem no send any money yet.',
  'expert.careHub': 'Care & protection hub',
  'expert.practiceProtected': 'Your work, fully protected',
  'expert.practiceProtectedBody':
      'Wetin Soothify dey cover for you, for every session you '
      'do.',
  'expert.noHoursSet': 'You no set any time yet',
  'expert.everyday': 'Every day',

  // ---------------------------------- expert: the two payout confirmations
  'expert.payoutUpdated': 'Dem Don Update How Dem Go Pay You',
  'expert.payoutUpdatedBody':
      'Your payout details don save well well. Na di way you pick '
      'dem go use send your money from now.',
  'expert.withdrawalSent': 'Di Money Don Comot',
  'expert.withdrawalSentBody':
      'Dem don receive your request. Di money go enter your '
      'payout account small time.',

  // --------------------------- user: profile, favourites, mood and journal
  'profile.myStats': 'My stats',
  'profile.weeklyGoal': 'Your target for dis week',
  'profile.goalReached': 'You don reach your target dis week.',
  'profile.recentActivity': 'Wetin you do recently',
  'profile.liveSessions': 'Live sessions',
  'favourites.title': 'Wetin You Like',
  'favourites.empty': 'You no save anything yet',
  'favourites.emptyBody':
      'Press di heart on anything inside di library, e go show '
      'here.',
  'mood.howDoYouFeel': 'How you dey feel today?',
  'mood.addDetail': 'Add More Detail',
  'mood.awful': 'E bad well well',
  'mood.awesome': 'E sweet',
  'mood.records': 'Mood Records',
  'common.returnHome': 'Go back home',
  'library.noMatches': 'Nothing here match wetin you pick.',
  'library.articles': 'Articles',
  'journal.title': 'Journal',
  'journal.empty': 'You no write anything yet',
  'journal.emptyBody':
      'No rule about wetin you go write inside your Notepad. '
      'Write how you dey feel, wetin you dey plan, or just '
      'something wey you notice.',

  // ----------------------- user: discovery, settings, passport and payment
  'discovery.spaces': 'Spaces Near Me',
  'discovery.spacesBody': 'Find studios and wellness places near you',
  'discovery.searchHint': 'Wetin you dey find?',
  'discovery.noResults': 'We no see anything',
  'passport.findRhythm': 'Find Your Own Rhythm',
  'passport.chooseBody':
      'Pick di passport level wey match how you dey practice.',
  'payment.success': 'Your payment don enter',

  // ------------------------------------------- user: the discovery shelves
  'discovery.recent': 'Recent',
  'discovery.popular': 'Wetin Hot',

  // ----------------------------------------------------- partner: the door
  'partner.checkInConfirmation': 'Check-in confirmation',
  'partner.checkInOk': 'Di check-in work',
  'partner.savedOnDevice': 'Check-in save on dis phone',
  'partner.offlineBody':
      'Network no dey. Dis check-in go sync by itself once '
      'network come back.',
  'partner.nextMember': 'Check in next member',
  'partner.backToRoster': 'Go back to roster',
  'partner.rosterTitle': 'Live roster & verification',
  'partner.offlineTitle': 'Network No Dey',
  'partner.offlineSync': 'Check-ins go sync by demself once network come back.',
  'partner.reportSent': 'Report don go admin log · Code Done Expire',
  'partner.frontDesk': 'Front desk verification',
  'partner.orUseCode':
      'Or use di member entry code if network or camera no gree '
      'work.',
  'partner.memberCode': 'Member entry code',
  'partner.codeHelp': 'Put di 6-letter code; di hyphen go come by itself.',
  'partner.checkInFailed': 'Di check-in no work',
  'partner.disputeCheckIn': 'Challenge Di Check-in',
  'partner.grantNowBody':
      'Allow am enter now. Dem go send di matter go admin log '
      'make dem check am.',
  'partner.passportMembers': 'Passport members',
  'partner.memberName': 'Member Name',
  'partner.tierTag': 'Tier Tag',
  'partner.checkInStatus': 'Check-in Status',

  // ------------------------ partner: the ledger, the schedule and the desk
  'partner.ledgerTitle': 'Studio payout ledger',
  'partner.financials': 'Money & Settlement Hub',
  'partner.ledgerBlurb':
      'Di check-ins dem confirm, your money, and wetin dem don '
      'pay you.',
  'partner.payoutSchedule':
      'Dem dey pay on 1st and 15th. If you wan challenge any '
      'check-in, do am within 48 hours.',
  'partner.unpaidBalance': 'Money Wey Gather But Dem No Pay Yet',
  'partner.queuedForSettlement': 'E dey line up for your next settlement',
  'partner.nextDisbursement': 'Next Payment',
  'partner.every1st15th': 'Every 1st & 15th',
  'partner.lifetimeEarnings': 'All Di Money So Far',
  'partner.totalToDate': 'Everything you don earn till now',
  'partner.wholesaleAmount': 'Wholesale Payout Amount',
  'partner.disputeCheckInShort': 'Challenge Check-In',
  'partner.earnings': 'Money',
  'partner.disputeTitle': 'Challenge check-in',
  'partner.disputeBody':
      'Pick all di reasons wey apply. Di member still go enter '
      'class while dem dey check am.',
  'partner.entryNowReviewLater': 'Make dem enter now, check am later',
  'partner.provisionalBody':
      'Status go turn Provisionally Verified. Dem go send report '
      'go admin log.',
  'partner.submitAndGrant': 'Send Am & Allow Entry',
  'partner.passportOnly': 'Master schedule · Passport classes only',
  'partner.classDetails': 'Class details',
  'partner.availableKinds': 'Wetin dey: Reformer · Mat · Yoga',
  'partner.recurrence': 'Make am repeat by itself',
  'partner.offPeak': 'Mark Am As Off-Peak Session',
  'partner.backToDesk': 'Go back to di desk',
  'partner.live': 'Live',
  'partner.bookingsLive': 'Booking dey update by itself as e dey happen.',
  'partner.newBooking': 'New Booking Request!',

  // ------------------------------------------------------ auth: getting in
  'auth.welcome': 'Welcome',
  'auth.roleQuestion': 'How you wan use Soothify Africa?',
  'auth.roleListen': 'I come here to listen',
  'auth.rolePractitioner': 'I be practitioner',
  'auth.introWelcome': 'Welcome to Soothify',
  'auth.getStarted': 'Make we start',
  'auth.skip': 'Skip',
  'auth.codeSentBlurb':
      'We don send six-number code go your email. Put am below.',
  'auth.sixDigitCode': 'Six-number code',
  'auth.confirmEmailTitle': 'Confirm your email',
  'auth.confirmMyEmail': 'Confirm my email',
  'auth.sending': 'E dey send…',
  'auth.sendAnotherCode': 'Send another code',
  'auth.differentEmail': 'Use another email',
  'auth.resetPassword': 'Change your password',
  'auth.resetBlurb': 'We go send six-number code go your email.',
  'auth.emailAddress': 'Email Address',
  'auth.sendTheCode': 'Send di code',
  'auth.enterTheCode': 'Put di code',
  'auth.newPassword': 'New password',
  'auth.setMyPassword': 'Set my password',
  'auth.logInTitle': 'Log in to your account',
  'auth.welcomeBackBrand': 'Welcome back to SoothifyAfrica!',
  'auth.password': 'Password',
  'auth.forgotPassword': 'You don forget your password?',
  'auth.noAccount': 'You no get account? Sign up',
  'auth.createAccountTitle': 'Open your account',
  'auth.signupBlurb':
      'No fear, your personal information dey safe and we no dey '
      'give am to any other person.',
  'auth.fullname': 'Your full name',
  'auth.confirmPassword': 'Confirm password',
  'auth.passwordsDiffer': 'Di two passwords no be di same.',
  'auth.createAccount': 'Open Account',
  'auth.haveAccount': 'You get account already? Log in',

  // ----------------------------------------------------- the settings rows
  'settings.manageSubscription': 'Manage subscription',
  'settings.account': 'Account',
  'settings.favourites': 'Wetin You Like',
  'settings.careProtection': 'Care & protection hub',
  'settings.themeToggle': 'Light Mode',
  'settings.changeLanguage': 'Change Language',
  'settings.notifications': 'Notifications',
  'settings.becomeExpert': 'Become Expert',
  'settings.privacyPolicy': 'Privacy Policy',
  'settings.terms': 'Terms & Conditions',
  'settings.about': 'About Us',
  'settings.logout': 'Log out',

  // ------------------------------- user: media, spaces, videos and booking
  'media.cannotOpen': 'We no be able open dat content.',
  'media.goBack': 'Go Back',
  'media.rateThis': 'Rate am',
  'media.yourRating': 'How you rate am',
  'media.addNote': 'Add Note',
  'spaces.searchHint': 'Find quiet place near you...',
  'spaces.useLocation': 'Use my location make I sabi how far dem dey',
  'spaces.noMatches':
      'No space match dat yet. Try another filter, or open your '
      'search small.',
  'spaces.noLocations': 'None of dem get location yet',
  'spaces.tapPin': 'Press any pin make you see di space',
  'spaces.directions': 'Show Me Road',
  'videos.title': 'Videos',
  'videos.empty': 'No video dey here yet.',
  'booking.pickDay': 'Pick di day for your session',
  'booking.pickTime': 'Pick di time',
  'booking.noTimes': 'No time remain for dis day. Try another one.',
  'booking.confirm': 'Confirm di booking',
  'subscription.title': 'Your Subscription',
  'subscription.inactive': 'E No Dey Work',
  'subscription.none': 'You no get subscription wey dey work now.',
  'subscription.pitch':
      'Get as many expert-led yoga and Pilates classes as you '
      'want, download dem to watch offline, plus small small '
      'wellness routine every day.',
  'subscription.pastReceipts': 'See old receipts',
  'subscription.details': 'Subscription details',
  'subscription.changePlan': 'Change Plan',
  'subscription.cancel': 'Cancel Subscription',
  'subscription.update': 'Change am',
  'payment.securePlace':
      'Hold your space so you go get your calendar link and '
      'start.',
  'payment.waiting': 'Dey wait for payment…',
  'payment.openingCheckout': 'Dey open checkout…',
  'payment.payWithCard': 'Pay with card',

  // ------------------------------------------------- the last of the words
  'kyc.age': 'Age',
  'kyc.years': 'yrs',
  'expert.recommendContents': 'Recommend Content',
  'expert.joiningLive': 'You dey join live session with your client.',
  'media.instructor': 'Instructor',
  'ai.guide': 'Wellness Guide',
  'journal.changePrompt': 'Change di question',
  'journal.recommendedContent': 'Content Wey Dem Recommend',
  'journal.expertNote': 'Wetin Di Expert Write',
  'journal.recentLive': 'Live Sessions Wey Just Happen',
  'journal.earlier': 'Older Sessions',
  'payment.cancellationPolicy': 'Cancellation Policy',
  'payment.andPolicy': 'Payment & Policy',
  'payment.session': 'Session',
  'payment.total': 'Total',
  'payment.totalToday': 'Total for today',
  'payment.pay': 'Pay',
  'payment.apply': 'Use am',
  'settings.deleteTitle': 'You wan delete your account?',
  'settings.keepAccount': 'Keep my account',
  'settings.delete': 'Delete am',
  'settings.confirmPassword':
      'Put your password to confirm. You no go be able undo dis '
      'one.',
  'session.safeSpace': 'Your Safe Space Dey Protected',
  'profile.myCalendar': 'My Calendar',
  'spaces.notListed': 'Dat studio no dey listed again.',
  'booking.matchedWith': 'See! You match with',
  'booking.selectDates': 'Pick di dates',
  'application.expertise': 'Wetin you sabi pass?',
  'application.submitted': 'Dem Don Receive Your Application!',
  'partner.addSlotTitle': 'Add Soothify Class Slot',
  'partner.spotAllocation': 'Soothify Passport Spot Allocation',
  'partner.offPeakBody': 'E go show more for Soothify app feed.',
  'partner.scheduleHeader': 'Master schedule & Soothify slots',
  'partner.slotManager': 'Soothify slot manager',
};
