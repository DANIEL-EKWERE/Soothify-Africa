/// The app's own words, in English.
///
/// Keys are dotted and grouped by where they appear. The English value is
/// the source of truth: it is what the screens used to hold literally, and
/// what Pidgin is translated from.
const Map<String, String> en = {
  // ------------------------------------------------------------ language
  'language.title': 'How would you like to converse?',
  'language.subtitle': 'Choose your preferred language.',
  'language.continue': 'Continue',

  // ---------------------------------------------------------------- nav
  'nav.home': 'Home',
  'nav.plans': 'Plans',
  'nav.discovery': 'Discovery',
  'nav.community': 'Community',
  'nav.profile': 'Profile',
  'nav.schedule': 'Schedule',
  'nav.earnings': 'Earnings',
  'nav.notes': 'Notes',

  // --------------------------------------------------------------- home
  'home.greetingMorning': 'Good morning',
  'home.greetingAfternoon': 'Good afternoon',
  'home.greetingEvening': 'Good evening',
  'home.howAreYou': 'How are you today?',
  'home.explore': 'Explore',
  'home.recommended': 'Recommended for you',
  'home.popular': 'Popular Content',
  'home.seeAll': 'See All',
  'home.seeMore': 'See more',
  'home.moodChecker': 'Mood Checker',
  'home.moodCheckerBody':
      'Take a moment to check in with yourself, acknowledging how you truly '
      'feel.',

  // -------------------------------------------------------------- common
  'common.cancel': 'Cancel',
  'common.save': 'Save',
  'common.continue': 'Continue',
  'common.retry': 'Try Again',
  'common.back': 'Back',
  'common.next': 'Next',
  'common.done': 'Done',

  // --------------------------------------------------------------- plans
  'plans.title': 'Plans',
  'plans.monthly': 'Monthly',
  'plans.annual': 'Annual',
  'plans.startTrial': 'Start 7-Day Free Trial',
  'plans.chooseTier': 'Choose Your Tier',
  'plans.corporate': 'Speak with Corporate Team',

  // -------------------------------------------------------------- expert
  'expert.welcomeBack': 'Welcome back,',
  'expert.difference': 'You’re making a real difference.',
  'expert.upcomingSessions': 'Upcoming Sessions',
  'expert.joinCall': 'Join call',
  'expert.quickActions': 'Quick Actions',
  'expert.earningsTitle': 'Earnings',
  'expert.availableEarnings': 'Available Earnings',
  'expert.withdraw': 'Withdraw',

  // ------------------------------------------------------------- partner
  'partner.dashboard': 'Soothify Partner Dashboard',
  'partner.overview': 'Overview',
  'partner.guestList': 'Active Guest List',
  'partner.pendingBookings': 'Pending Bookings',
  'partner.confirmedToday': 'Confirmed Today',
  'partner.monthlyPayout': 'Monthly Payout Accrued',
  'partner.realTime': 'Real-Time Notifications',
  'partner.todaysGuests': 'Today’s Guests',
  'partner.checkedIn': 'Checked In',
  'partner.awaitingArrival': 'Awaiting Arrival',
  'partner.scanQr': 'Scan Passport QR Code',
  'partner.verifyCode': 'Verify Entry Code',

  // ----------------------------------- expert: profile, notes and earnings
  'expert.profileBody':
      'Your availability, session notes and earnings are on their '
      'own tabs.',
  'expert.settings': 'Settings',
  'expert.switchRole': 'Switch role',
  'expert.sessionNotes': 'Session notes',
  'expert.notesBlurb':
      'Keep track of your sessions and client progress, key '
      'insight and next steps.',
  'expert.recentPayouts': 'Recent payouts',
  'common.seeAll': 'See All',
  'expert.bankCharge': '10% bank service charges applies.',
  'expert.nextPayout': 'Next automatic payout',
  'expert.payoutMethod': 'Payout method',
  'expert.notSet': 'Not set',
  'expert.thisWeek': 'This week',
  'expert.totalEarned': 'Total earned',

  // ---------------------------------------- expert: dashboard and schedule
  'expert.totalThisWeek': 'Total Earnings this week',
  'expert.nothingBooked': 'Nothing booked yet.',
  'expert.updateAvailability': 'Update Availability',
  'expert.updateAvailabilityBody': 'Set your available days and time slots.',
  'expert.addSessionNotes': 'Add Session Notes',
  'expert.addSessionNotesBody':
      'Keep track of your sessions and client progress.',
  'expert.upcomingSession': 'Upcoming Session',

  // ---------------------------------- expert: session notes and withdrawal
  'expert.howDidItGo': 'How did the session go',
  'expert.sessionSummary': 'Session Summary',
  'expert.recommendation': 'Recommendation',
  'expert.notesHint':
      'How did the session go? Add notes about the client’s '
      'progress, key topics discussed, observations or next steps',
  'expert.saving': 'Saving…',
  'expert.sendSomething': 'Send them something to work with',
  'expert.withdrawal': 'Withdrawal',
  'expert.withdrawHowMuch': 'How much do you want to withdraw',
  'expert.destination': 'Destination of funds',
  'expert.addPayoutAccount': '+  Add a payout account',

  // ----------------------- expert: payout method, bank details and outcome
  'expert.payoutMethodHeading': 'Payout Method',
  'expert.payoutMethodBody':
      'This is where your earnings will be sent. You can edit '
      'your details anytime.',
  'expert.addNewPayoutMethod': '+  Add New Payout Method',
  'expert.backToEarnings': 'Back to Earnings',
  'expert.bankTransferNgn': 'Bank Transfer (NGN)',
  'expert.active': 'Active',
  'expert.chooseMethodBody':
      'Choose how you’d like to receive your payments from '
      'Soothify.',
  'common.proceed': 'Proceed',
  'expert.paystackNote': 'All payments are processed securely by Paystack.',
  'expert.bankDetailsTitle': 'Bank Transfer Details',
  'expert.bankDetailsBody':
      'Enter your bank account details to receive payment in '
      'Nigerian Naira (NGN)',
  'expert.bankName': 'Bank Name',
  'expert.accountNumber': 'Account Number',
  'expert.accountName': 'Account Name',
  'expert.addBankDetails': 'Add Bank Details',
  'expert.selectBank': 'Select Bank',
  'expert.paymentMethod': 'Payment Method',
  'expert.noPayouts': 'No payouts yet.',
  'expert.careHub': 'Care & protection hub',
  'expert.practiceProtected': 'Your practice, fully protected',
  'expert.practiceProtectedBody':
      'What Soothify covers for you, on every session you take.',
  'expert.noHoursSet': 'No hours set yet',
  'expert.everyday': 'Everyday',

  // ---------------------------------- expert: the two payout confirmations
  'expert.payoutUpdated': 'Payout Method Updated',
  'expert.payoutUpdatedBody':
      'Your payout details have been saved successfully. You’ll '
      'now receive your earnings based on your selected method.',
  'expert.withdrawalSent': 'Withdrawal Successful',
  'expert.withdrawalSentBody':
      'Your withdrawal request has been submitted successfully. '
      'The funds will be sent to your payout account shortly.',

  // --------------------------- user: profile, favourites, mood and journal
  'profile.myStats': 'My stats',
  'profile.weeklyGoal': 'Your weekly goal',
  'profile.goalReached': 'You have reached your goal this week.',
  'profile.recentActivity': 'Recent activity',
  'profile.liveSessions': 'Live sessions',
  'favourites.title': 'Favourites',
  'favourites.empty': 'Nothing saved yet',
  'favourites.emptyBody':
      'Tap the heart on anything in the library and it will be '
      'here.',
  'mood.howDoYouFeel': 'How do you feel today?',
  'mood.addDetail': 'Add Detail',
  'mood.awful': 'Awful',
  'mood.awesome': 'Awesome',
  'mood.records': 'Mood Records',
  'common.returnHome': 'Return home',
  'library.noMatches': 'Nothing here matches your filters.',
  'library.articles': 'Articles',
  'journal.title': 'Journal',
  'journal.empty': 'No entries yet',
  'journal.emptyBody':
      'There are no limits on topics in your Notepad. Write down '
      'how feel, what you’re planning, or simply something you '
      'noticed.',

  // ----------------------- user: discovery, settings, passport and payment
  'discovery.spaces': 'Spaces Around Me',
  'discovery.spacesBody': 'Find studios & wellness spaces near you',
  'discovery.searchHint': 'What can we help you find?',
  'discovery.noResults': 'No results found',
  'passport.findRhythm': 'Find Your Rhythm',
  'passport.chooseBody':
      'Choose the passport tier that matches your practice level.',
  'payment.success': 'Your payment was successful',

  // ------------------------------------------- user: the discovery shelves
  'discovery.recent': 'Recent',
  'discovery.popular': 'Popular',

  // ----------------------------------------------------- partner: the door
  'partner.checkInConfirmation': 'Check-in confirmation',
  'partner.checkInOk': 'Check-in successful',
  'partner.savedOnDevice': 'Check-in saved on this device',
  'partner.offlineBody':
      'Offline mode is active. This check-in will sync '
      'automatically when reconnected.',
  'partner.nextMember': 'Check in next member',
  'partner.backToRoster': 'Back to roster',
  'partner.rosterTitle': 'Live roster & verification',
  'partner.offlineTitle': 'Offline Mode Active',
  'partner.offlineSync': 'Check-ins will sync automatically when reconnected.',
  'partner.reportSent': 'Report sent to admin log · Code Expired',
  'partner.frontDesk': 'Front desk verification',
  'partner.orUseCode':
      'Or use the member’s entry code if the network or camera '
      'fails.',
  'partner.memberCode': 'Member entry code',
  'partner.codeHelp': 'Enter the 6-character code; the hyphen is automatic.',
  'partner.checkInFailed': 'Check-in unsuccessful',
  'partner.disputeCheckIn': 'Dispute Check in',
  'partner.grantNowBody':
      'Grant entry now. The issue will be sent to the admin log '
      'for review.',
  'partner.passportMembers': 'Passport members',
  'partner.memberName': 'Member Name',
  'partner.tierTag': 'Tier Tag',
  'partner.checkInStatus': 'Check-in Status',

  // ------------------------ partner: the ledger, the schedule and the desk
  'partner.ledgerTitle': 'Studio payout ledger',
  'partner.financials': 'Financials & Settlement Hub',
  'partner.ledgerBlurb': 'Your verified check-ins, earnings and payouts.',
  'partner.payoutSchedule':
      'Payouts are processed on the 1st and 15th. Dispute a '
      'check-in within 48 hours.',
  'partner.unpaidBalance': 'Accrued Unpaid Balance',
  'partner.queuedForSettlement': 'Queued for your next settlement',
  'partner.nextDisbursement': 'Next Disbursement',
  'partner.every1st15th': 'Every 1st & 15th',
  'partner.lifetimeEarnings': 'Lifetime Earnings',
  'partner.totalToDate': 'Total earned to date',
  'partner.wholesaleAmount': 'Wholesale Payout Amount',
  'partner.disputeCheckInShort': 'Dispute Check-In',
  'partner.earnings': 'Earnings',
  'partner.disputeTitle': 'Dispute check-in',
  'partner.disputeBody':
      'Select all reasons that apply. The member can enter class '
      'while this is reviewed.',
  'partner.entryNowReviewLater': 'Entry now, review later',
  'partner.provisionalBody':
      'Status becomes Provisionally Verified. A report is sent to '
      'the admin log.',
  'partner.submitAndGrant': 'Submit & Grant Entry',
  'partner.passportOnly': 'Master schedule · Passport classes only',
  'partner.classDetails': 'Class details',
  'partner.availableKinds': 'Available: Reformer · Mat · Yoga',
  'partner.recurrence': 'Recurrence automation',
  'partner.offPeak': 'Mark as Off-Peak Session',
  'partner.backToDesk': 'Back to the desk',
  'partner.live': 'Live',
  'partner.bookingsLive': 'Bookings update automatically in real time.',
  'partner.newBooking': 'New Booking Request!',

  // ------------------------------------------------------ auth: getting in
  'auth.welcome': 'Welcome',
  'auth.roleQuestion': 'How will you be using Soothify Africa?',
  'auth.roleListen': 'I am here to listen',
  'auth.rolePractitioner': 'I am a practitioner',
  'auth.introWelcome': 'Welcome to Soothify',
  'auth.getStarted': 'Get started',
  'auth.skip': 'Skip',
  'auth.codeSentBlurb':
      'We sent a six-digit code to your email address. Enter it '
      'below.',
  'auth.sixDigitCode': 'Six-digit code',
  'auth.confirmEmailTitle': 'Confirm your email',
  'auth.confirmMyEmail': 'Confirm my email',
  'auth.sending': 'Sending…',
  'auth.sendAnotherCode': 'Send another code',
  'auth.differentEmail': 'Use a different email',
  'auth.resetPassword': 'Reset your password',
  'auth.resetBlurb': 'We will email you a six-digit code.',
  'auth.emailAddress': 'Email Address',
  'auth.sendTheCode': 'Send the code',
  'auth.enterTheCode': 'Enter the code',
  'auth.newPassword': 'New password',
  'auth.setMyPassword': 'Set my password',
  'auth.logInTitle': 'Log in to your account',
  'auth.welcomeBackBrand': 'Welcome back to SoothifyAfrica!',
  'auth.password': 'Password',
  'auth.forgotPassword': 'Have you forgotten password?',
  'auth.noAccount': 'Don’t have an account? Sign up',
  'auth.createAccountTitle': 'Create your account',
  'auth.signupBlurb':
      'Rest assured that your personal information is securely '
      'protected and never shared with third parties.',
  'auth.fullname': 'Fullname',
  'auth.confirmPassword': 'Confirm password',
  'auth.passwordsDiffer': 'Passwords do not match.',
  'auth.createAccount': 'Create Account',
  'auth.haveAccount': 'Already have an account? Log in',

  // ----------------------------------------------------- the settings rows
  'settings.manageSubscription': 'Manage subscription',
  'settings.account': 'Account',
  'settings.favourites': 'Favourites',
  'settings.careProtection': 'Care & protection hub',
  'settings.themeToggle': 'Light Mode',
  'settings.changeLanguage': 'Change Language',
  'settings.notifications': 'Notifications',
  'settings.becomeExpert': 'Become an Expert',
  'settings.privacyPolicy': 'Privacy Policy',
  'settings.terms': 'Terms & Conditions',
  'settings.about': 'About Us',
  'settings.logout': 'Logout',

  // ------------------------------- user: media, spaces, videos and booking
  'media.cannotOpen': 'That content could not be opened.',
  'media.goBack': 'Go back',
  'media.rateThis': 'Rate this',
  'media.yourRating': 'Your rating',
  'media.addNote': 'Add Note',
  'spaces.searchHint': 'Find a quiet space near you...',
  'spaces.useLocation': 'Use my location to see how far away these are',
  'spaces.noMatches':
      'No spaces match that yet. Try another filter, or widen '
      'your search.',
  'spaces.noLocations': 'None of these have a location yet',
  'spaces.tapPin': 'Tap a pin to preview a space',
  'spaces.directions': 'Get Directions',
  'videos.title': 'Videos',
  'videos.empty': 'No videos here yet.',
  'booking.pickDay': 'Pick a day for your session',
  'booking.pickTime': 'Pick a time',
  'booking.noTimes': 'No times left on this day. Try another.',
  'booking.confirm': 'Confirm booking',
  'subscription.title': 'Your Subscription',
  'subscription.inactive': 'Inactive',
  'subscription.none': 'You currently don’t have an active subscription.',
  'subscription.pitch':
      'Unlock unlimited access to all expert-led yoga & Pilates '
      'classes, offline streaming, and daily wellness '
      'micro-routines.',
  'subscription.pastReceipts': 'View past receipts',
  'subscription.details': 'Subscription details',
  'subscription.changePlan': 'Change Plan',
  'subscription.cancel': 'Cancel Subscription',
  'subscription.update': 'Update',
  'payment.securePlace':
      'Secure your spot to unlock your calendar link and start '
      'your journey',
  'payment.waiting': 'Waiting for payment…',
  'payment.openingCheckout': 'Opening checkout…',
  'payment.payWithCard': 'Pay with card',

  // ------------------------------------------------- the last of the words
  'kyc.age': 'Age',
  'kyc.years': 'yrs',
  'expert.recommendContents': 'Recommend Contents',
  'expert.joiningLive': 'You’re joining a live session with your client.',
  'media.instructor': 'Instructor',
  'ai.guide': 'Wellness Guide',
  'journal.changePrompt': 'Change prompt',
  'journal.recommendedContent': 'Recommended Content',
  'journal.expertNote': 'Expert’s Note',
  'journal.recentLive': 'Recent Live Sessions',
  'journal.earlier': 'Earlier Sessions',
  'payment.cancellationPolicy': 'Cancellation Policy',
  'payment.andPolicy': 'Payment & Policy',
  'payment.session': 'Session',
  'payment.total': 'Total',
  'payment.totalToday': 'Total today',
  'payment.pay': 'Pay',
  'payment.apply': 'Apply',
  'settings.deleteTitle': 'Delete your account?',
  'settings.keepAccount': 'Keep my account',
  'settings.delete': 'Delete',
  'settings.confirmPassword':
      'Enter your password to confirm. This cannot be undone.',
  'session.safeSpace': 'Your Safe Space is Protected',
  'profile.myCalendar': 'My Calendar',
  'spaces.notListed': 'That studio is no longer listed.',
  'booking.matchedWith': 'Awesome! You matched with',
  'booking.selectDates': 'Select dates',
  'application.expertise': 'What are your primary areas of expertise?',
  'application.submitted': 'Application Submitted!',
  'partner.addSlotTitle': 'Add Soothify Class Slot',
  'partner.spotAllocation': 'Soothify Passport Spot Allocation',
  'partner.offPeakBody': 'Gives higher visibility in Soothify app feed.',
  'partner.scheduleHeader': 'Master schedule & Soothify slots',
  'partner.slotManager': 'Soothify slot manager',
};
