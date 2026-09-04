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

  /// Mood emoji are addressed through [Mood.assetPath] rather than listed
  /// here, so adding a mood does not mean editing two files.
  static const String moodsDir = '$_images/moods';
}
