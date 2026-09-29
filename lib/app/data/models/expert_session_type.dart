/// The three cards on "Book a licensed expert screen" — Figma `259:31488`
/// (light) and `259:31885` (dark).
///
/// Not the same set as [SessionOffering]: that one is therapy, Pilates & Core
/// and Stretch & Restore, which are the app's *sections*. This screen offers
/// therapy, **yoga** and Pilates — the disciplines a licensed expert is booked
/// for, which is why the KYC row behind it is named `Scheduling Kyc/Yoga`.
enum ExpertSessionType {
  therapy(
    '1-on-1 virtual therapy session',
    'assets/images/explore/book_expert.png',
  ),
  yoga(
    '1-on-1 virtual yoga session',
    'assets/images/explore/stretch_restore.png',
  ),
  // The frame writes "Pilates" capitalised mid-sentence on this card and
  // lowercase nowhere, so it is the product name rather than a slip.
  pilates(
    '1-on-1 virtual Pilates session',
    'assets/images/explore/pilates_core.png',
  );

  const ExpertSessionType(this.title, this.assetPath);

  final String title;

  /// A 294x150 photograph at the top of the card.
  ///
  /// **Stand-ins.** The frame carries three distinct image fills
  /// (`378815b9…`, `3d2bba51…`, `6bfb23f6…`) and the render endpoint's quota
  /// was spent before they could be exported. These are the Explore tiles of
  /// the nearest subject, which ship at 200x180 — fine for a 100x90 tile,
  /// soft at 294x150. Replace all three when the exports land.
  final String assetPath;

  /// The design prints the same second line on all three cards.
  String get blurb => 'One on one session with a\nprofessional';
}
