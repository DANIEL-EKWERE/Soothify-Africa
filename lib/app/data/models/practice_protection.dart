/// The three assurances on "Care & protection hub".
///
/// Data rather than markup so the screen is a list and the copy lives in one
/// place — the same shape [SettingsEntry] uses.
enum PracticeProtection {
  noShow(
    'No-Show Protection',
    'If a client cancels less than 2 hours before a session, your payout is '
        'automatically guaranteed.',
    'ic_security',
  ),
  secureNotes(
    'Secure Note Storage',
    'All clinical session records are encrypted and stored safely for you.',
    'lock',
  ),
  spotlight(
    'Community Spotlight',
    'Top-rated practitioners receive priority placement for our corporate '
        'B2B wellness events.',
    'nav_community',
  );

  const PracticeProtection(this.title, this.body, this._icon);

  final String title;
  final String body;
  final String _icon;

  String get asset => 'assets/icons/$_icon.svg';
}
