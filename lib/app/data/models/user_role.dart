/// The three audiences the app serves: the member, the practitioner who
/// sees them, and the studio whose floor a Passport member books.
enum UserRole {
  user('user'),
  practitioner('practitioner'),

  /// A studio, in its own portal — Figma `4968:32935` and `4968:32751`.
  /// Not a member with extra screens: a partner has no library, no journal
  /// and no plans, and signs in to answer bookings and work the door.
  partner('partner');

  const UserRole(this.key);

  final String key;

  static UserRole? fromKey(String? key) {
    if (key == null) return null;
    for (final role in UserRole.values) {
      if (role.key == key) return role;
    }
    return null;
  }
}
