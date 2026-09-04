/// The three counters on the Profile "My stats" card.
///
/// All three are minutes-or-counts the backend will own once it exists; the
/// design shows them at zero, which is also a new account's true state.
class ProfileStats {
  const ProfileStats({
    this.meditationMinutes = 0,
    this.balanceMinutes = 0,
    this.liveSessions = 0,
  });

  final int meditationMinutes;
  final int balanceMinutes;
  final int liveSessions;

  static const ProfileStats empty = ProfileStats();

  /// DRF returns snake_case; these keys match that contract.
  factory ProfileStats.fromJson(Map<String, dynamic> json) => ProfileStats(
        meditationMinutes: json['meditation_minutes'] as int? ?? 0,
        balanceMinutes: json['balance_minutes'] as int? ?? 0,
        liveSessions: json['live_sessions'] as int? ?? 0,
      );
}

/// The Profile screen's three views, in the order the design lays them out.
///
/// Only [dashboard] is built; the design has separate frames for the other
/// two (Profile/history, Profile/mood checkin).
enum ProfileSection {
  dashboard('Dashboard'),
  history('History'),
  checkIns('Check-Ins');

  const ProfileSection(this.label);

  final String label;
}
