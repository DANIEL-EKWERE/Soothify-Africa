/// Asset paths, exported from the Figma file.
class ImageConstant {
  const ImageConstant._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  static const String imgPlaceholder = '$_images/img_placeholder.png';

  /// Script wordmark, exported from Figma. White fill, 194x77.
  static const String svgWordmark = '$_icons/wordmark.svg';

  /// Circular logo mark used on the auth screen.
  static const String imgLogoMark = '$_images/logo_mark.png';

  static const String imgAuthHeaderIcon = '$_images/auth/auth_header_icon.png';
  static const String imgGoogle = '$_images/auth/google.png';

  static const String icChevronLeft = '$_icons/ic_chevron_left.svg';
  static const String icArrowLeft = '$_icons/ic_arrow_left.svg';
  static const String icTickCircle = '$_icons/ic_tick_circle.svg';
  static const String icEyeHidden = '$_icons/ic_eye_hidden.svg';

  /// Content cover art, exported from Figma. Addressed by slug from the
  /// repository rather than listed one by one, so adding an item does not
  /// mean editing this file too.
  static const String contentDir = '$_images/content';

  static const String imgMoodCheckerIcon = '$_images/home/mood_checker_icon.png';
  static const String imgAiAssist = '$_images/home/ai_assist.png';

  /// The Community welcome illustration, exported from the frame itself.
  static const String imgCommunityWelcome = '$_images/community/welcome.png';

  /// The member avatar the Community and forum frames show.
  static const String imgCommunityAvatar = '$_images/community/avatar.png';

  static const String imgMemberAvatar = '$_images/community/avatar_member.png';
  static const String imgJournalEmpty = '$_images/journal/empty.png';
  static const String imgJournalCompose = '$_images/journal/compose_fab.png';
  static const String imgSessionCover = '$_images/schedule/session.png';
  static const String imgHomeAvatar = '$_images/home/avatar.png';

  static const String imgAiAssistIcon = '$_images/home/ai_assist.png';

  static const String icDarkMode = '$_icons/ic_dark_mode.svg';

  static const String imgMediaInstructor = '$_images/media/instructor.png';
  static const String imgMediaBadge = '$_images/media/badge.png';

  static const String icBell = '$_icons/ic_bell.svg';
  static const String icRefresh = '$_icons/ic_refresh.svg';
  static const String icMenu = '$_icons/ic_menu.svg';
  static const String icEditBadge = '$_icons/ic_edit_badge.svg';

  static const String imgCoachPhoto = '$_images/coach/photo.png';
  static const String imgCoachVideo = '$_images/coach/video.png';
  static const String imgCoachBanner = '$_images/coach/banner.png';
  static const String imgCoachCallAvatar = '$_images/coach/call_avatar.png';

  /// The "Other Instructors Matches" row.
  static List<String> get imgCoachPeers => const [
        '$_images/coach/peer_1.png',
        '$_images/coach/peer_2.png',
        '$_images/coach/peer_3.png',
        '$_images/coach/peer_4.png',
      ];

  static const String icOthers = '$_icons/ic_others.svg';

  static const String icBack = '$_icons/ic_back.svg';
  static const String icSearch = '$_icons/ic_search.svg';
  static const String icFilter = '$_icons/ic_filter.svg';
  static const String icSend = '$_icons/ic_send.svg';
  static const String icStar = '$_icons/ic_star.svg';
  static const String icMore = '$_icons/ic_more.svg';
  static const String icLike = '$_icons/ic_like.svg';
  static const String icComment = '$_icons/ic_comment.svg';
  static const String icShare = '$_icons/ic_share.svg';
  static const String icReply = '$_icons/ic_reply.svg';
  static const String icLocation = '$_icons/ic_location.svg';
  static const String icLiveSession = '$_icons/ic_live_session.svg';
  /// The three white line icons inside the guest sign-up card, and the gear
  /// and person glyphs beside it — cropped from the rendered frame, because
  /// the /nodes endpoint that would give their own ids is rate-limited.
  /// Notification feed art, cropped from the rendered frame — the /nodes
  /// endpoint that would give these their own ids is rate-limited. The frame
  /// gives two of its three people the same portrait.
  static const String imgAvatarMale = '$_images/notifications/avatar_male.png';
  static const String imgAvatarFemale =
      '$_images/notifications/avatar_female.png';
  static const String icReminder = '$_images/notifications/ic_reminder.png';
  /// The digest's heart is solid in the frame; [icHeart] is the outline
  /// the media cards use.
  static const String icHeartFilled =
      '$_images/notifications/ic_heart_filled.png';

  static const String imgSignupClock = '$_images/profile/signup_clock.png';
  static const String imgSignupCalendar = '$_images/profile/signup_calendar.png';
  static const String imgSignupMind = '$_images/profile/signup_mind.png';
  static const String icSettingsGear = '$_images/profile/ic_settings_gear.png';
  static const String icPerson = '$_images/profile/ic_person.png';
  static const String imgStatMeditation = '$_images/profile/stat_meditation.png';
  static const String imgStatBalance = '$_images/profile/stat_balance.png';

  static const String icHeart = '$_icons/ic_heart.svg';
  static const String icLock = '$_icons/lock.svg';
  static const String icPlay = '$_icons/play.svg';
  static const String icMoon = '$_icons/ic_moon.svg';
  static const String icArrowRight = '$_icons/ic_arrow_right.svg';

  /// Mood emoji are addressed through [Mood.assetPath] rather than listed
  /// here, so adding a mood does not mean editing two files.
  static const String moodsDir = '$_images/moods';
}
