/// The two audiences the app serves. Practitioner screens are not designed
/// yet — the role exists so routing and bindings have a seam to grow into.
enum UserRole {
  user('user'),
  practitioner('practitioner');

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
