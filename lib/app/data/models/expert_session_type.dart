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
    'assets/images/expert/therapy.png',
  ),
  yoga(
    '1-on-1 virtual yoga session',
    'assets/images/expert/yoga.png',
  ),
  // The frame writes "Pilates" capitalised mid-sentence on this card and
  // lowercase nowhere, so it is the product name rather than a slip.
  pilates(
    '1-on-1 virtual Pilates session',
    'assets/images/expert/pilates.png',
  );

  const ExpertSessionType(this.title, this.assetPath);

  final String title;

  /// A 294x150 photograph at the top of the card.
  ///
  /// The frame's own fills, pulled through `files/{key}/images` — the fourth
  /// Figma budget, which was still open when the other three were spent.
  /// Refs `378815b9…` (therapy), `3d2bba51…` (yoga), `6bfb23f6…` (Pilates).
  ///
  /// Exported at 2x with a centre-cover crop, matching the frame's `FILL`
  /// scale mode. Therapy's source is only 360 square, so 588x300 is already a
  /// mild upscale; the other two had far more to give.
  final String assetPath;

  /// The design prints the same second line on all three cards.
  String get blurb => 'One on one session with a\nprofessional';
}
