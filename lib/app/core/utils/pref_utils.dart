import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key-value preferences. Auth tokens belong in secure storage, not here.
class PrefUtils {
  PrefUtils._();

  static final PrefUtils instance = PrefUtils._();
  factory PrefUtils() => instance;

  static SharedPreferences? _prefs;

  static const _kThemeMode = 'themeMode';
  static const _kUserRole = 'userRole';
  static const _kLanguage = 'language';
  static const _kIntroSeen = 'introSeen';
  static const _kOnboarded = 'hasOnboarded';
  static const _kWifiOnlyDownloads = 'wifiOnlyDownloads';
  static const _kCommunityWelcomeSeen = 'communityWelcomeSeen';
  static const _kCommunityUsername = 'communityUsername';

  /// Safe to call from anywhere that needs preferences before main() has run,
  /// such as a test or a service's own init.
  ///
  /// Re-resolves the store on every call rather than caching the first one.
  /// The instance is cheap to fetch, and holding the first forever meant a
  /// test that swapped in new mock values kept reading the previous test's —
  /// so routing decisions silently used stale state.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Drops the cached store so the next [init] re-reads it.
  ///
  /// The instance is cached statically, which is right for the app — it is
  /// loaded once at startup — but leaks between tests, where each case
  /// installs a fresh mock store. Without this, tests pass or fail depending
  /// on the order they run in.
  @visibleForTesting
  static void resetForTesting() => _prefs = null;

  /// Reads and writes used to no-op silently when [init] had not run, which
  /// turned an ordering mistake into preferences that quietly stopped
  /// persisting. Fail loudly in debug instead.
  SharedPreferences get _store {
    assert(
      _prefs != null,
      'PrefUtils.init() must be awaited before reading or writing preferences.',
    );
    return _prefs!;
  }

  /// 'system' | 'light' | 'dark'. Null until the user picks one.
  String? getThemeMode() => _store.getString(_kThemeMode);
  Future<void> setThemeMode(String value) async =>
      _store.setString(_kThemeMode, value);

  /// Language code ('en', 'pcm'). Null until the user picks one.
  String? getLanguage() => _store.getString(_kLanguage);
  Future<void> setLanguage(String value) async =>
      _store.setString(_kLanguage, value);

  /// Whether the welcome carousel has been shown. It is a first-run screen.
  bool introSeen() => _store.getBool(_kIntroSeen) ?? false;
  Future<void> setIntroSeen(bool value) async =>
      _store.setBool(_kIntroSeen, value);

  String? getUserRole() => _store.getString(_kUserRole);
  Future<void> setUserRole(String value) async =>
      _store.setString(_kUserRole, value);

  bool hasOnboarded() => _store.getBool(_kOnboarded) ?? false;
  Future<void> setOnboarded(bool value) async =>
      _store.setBool(_kOnboarded, value);

  /// Defaults to true — data cost matters in our target markets.
  bool wifiOnlyDownloads() => _store.getBool(_kWifiOnlyDownloads) ?? true;
  Future<void> setWifiOnlyDownloads(bool value) async =>
      _store.setBool(_kWifiOnlyDownloads, value);

  /// The community's own one-time welcome, separate from [introSeen] — it is
  /// shown the first time the Community tab is opened, not at app launch.
  bool communityWelcomeSeen() =>
      _store.getBool(_kCommunityWelcomeSeen) ?? false;
  Future<void> setCommunityWelcomeSeen(bool value) async =>
      _store.setBool(_kCommunityWelcomeSeen, value);

  /// The forum handle. Null until chosen; the community is pseudonymous, so
  /// this is deliberately not the account's real name.
  String? communityUsername() => _store.getString(_kCommunityUsername);
  Future<void> setCommunityUsername(String value) async =>
      _store.setString(_kCommunityUsername, value);

  Future<void> clearSession() async {
    await _store.remove(_kUserRole);
    // The handle is part of the session: a different account must not inherit
    // the previous one's forum identity.
    await _store.remove(_kCommunityUsername);
    await _store.remove(_kCommunityWelcomeSeen);
  }
}
