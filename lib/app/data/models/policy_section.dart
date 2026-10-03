/// A headed block on one of the long-form content pages — About Us, the
/// cancellation policy, and the two still outstanding.
///
/// The design holds none of this copy: the three Settings content frames are
/// duplicates of the Delete Account screen, and the booking flow's policy
/// frame carries two summary sentences. Everything here came from the
/// designer directly, so it lives beside the screens that print it rather
/// than inside any one of them.
class PolicySection {
  const PolicySection(this.heading, this.paragraphs);

  final String heading;

  /// One or more paragraphs, printed with a gap between them.
  final List<String> paragraphs;
}
