/// What the server hands back for joining a session's call.
///
/// Minted per person, per session, and only around the time it runs: the
/// room opens fifteen minutes before and closes fifteen after. A token
/// issued days early would be a key to a room left lying about, so the
/// app asks for one at the moment it needs it rather than holding one.
class CallCredentials {
  const CallCredentials({
    required this.appId,
    required this.token,
    required this.roomId,
    required this.userId,
    this.mode = 'video',
    this.expiresAt,
    this.recordingNotice = '',
  });

  /// ZEGOCLOUD's own ids. The app id is served rather than built in, so
  /// rotating it is a server change.
  final int appId;
  final String token;
  final String roomId;
  final String userId;

  /// 'video' or 'phone' — what was chosen when the session was booked.
  final String mode;

  final DateTime? expiresAt;

  /// What the person is told they are agreeing to. The server records the
  /// disclosure as it issues the token, so this is shown, never skipped.
  final String recordingNotice;

  bool get isVideo => mode != 'phone';

  factory CallCredentials.fromJson(Map<String, dynamic> json) =>
      CallCredentials(
        appId: json['app_id'] is int
            ? json['app_id'] as int
            : int.tryParse('${json['app_id']}') ?? 0,
        token: json['token'] as String? ?? '',
        roomId: json['room_id'] as String? ?? '',
        userId: '${json['user_id'] ?? ''}',
        mode: json['mode'] as String? ?? 'video',
        expiresAt: DateTime.tryParse('${json['expires_at']}')?.toLocal(),
        recordingNotice: json['recording_notice'] as String? ?? '',
      );

  /// Whether this is worth trying to join with.
  bool get isUsable =>
      appId > 0 && token.isNotEmpty && roomId.isNotEmpty && userId.isNotEmpty;
}
