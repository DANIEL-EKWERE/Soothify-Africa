import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/app_exception.dart';
import 'kyc_repository.dart';

/// On-device implementation, used while there is no backend.
///
/// When the Django API exists this becomes the local cache and a remote
/// implementation posts the answers; the interface does not change.
class LocalKycRepository implements KycRepository {
  static const _keyAnswers = 'kycAnswers';
  static const _keyComplete = 'kycComplete';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<Map<String, Set<String>>> savedAnswers() async {
    try {
      final raw = (await _prefs).getString(_keyAnswers);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, (v as List).map((e) => '$e').toSet()),
      );
    } catch (_) {
      // Corrupt or migrated data must not brick the questionnaire.
      throw const CacheException();
    }
  }

  @override
  Future<void> saveAnswers(Map<String, Set<String>> answers) async {
    final encoded = jsonEncode(
      answers.map((k, v) => MapEntry(k, v.toList())),
    );
    await (await _prefs).setString(_keyAnswers, encoded);
  }

  @override
  Future<bool> isComplete() async =>
      (await _prefs).getBool(_keyComplete) ?? false;

  @override
  Future<void> markComplete() async {
    await (await _prefs).setBool(_keyComplete, true);
  }
}
