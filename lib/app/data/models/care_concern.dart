/// What a client can report from the Care Support screen — Figma
/// `280:26747` (" Gentle Care Support Button", leading space in the name).
///
/// The first is the reason the screen exists: a practitioner steering a
/// client off-platform is the one that costs someone their protection, and
/// the frame draws it selected.
enum CareConcern {
  offPlatform('Practitioner suggested meeting outside the app'),
  uncomfortable('I felt uncomfortable during our session'),
  payment('I need help with a payment or scheduling issue'),
  other('Others', hint: ' (Please specify)');

  const CareConcern(this.label, {this.hint = ''});

  final String label;

  /// The frame greys this part to `#999999` where the label itself is body
  /// ink at 72% — so it reads as an instruction, not part of the choice.
  final String hint;
}
