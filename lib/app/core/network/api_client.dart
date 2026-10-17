import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';
import '../utils/logger.dart';

/// The Django API at `/api/v1/` — Soothify's own backend.
///
/// Deliberately thin. It adds four things to `package:http` and nothing
/// else: the base URL, the bearer header, a timeout, and the translation of
/// a status code into one of the app's [AppException]s. Everything above the
/// repository layer stays unaware that HTTP exists, which is the rule
/// [AppException] already states.
class ApiClient {
  ApiClient({
    http.Client? client,
    String? baseUrl,
    String Function()? accessToken,
    String Function()? refreshToken,
    Future<void> Function(String access, String refresh)? onTokens,
    Future<void> Function()? onSignedOut,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? defaultBaseUrl,
       _accessToken = accessToken ?? (() => ''),
       _refreshToken = refreshToken ?? (() => ''),
       _onTokens = onTokens,
       _onSignedOut = onSignedOut;

  /// Overridable at build time so a debug build can point at a laptop:
  ///
  ///   flutter run --dart-define=SOOTHIFY_API_BASE_URL=http://10.0.2.2:8000/api/v1
  ///
  /// The default is the live backend. It is the apex, not an `api.`
  /// subdomain: the API runs beside the website on cPanel and answers
  /// `/api/v1/` there. The subdomain is reserved for the day the API moves
  /// to AWS — until that name resolves, building against it means every
  /// request in the app fails at DNS.
  static const defaultBaseUrl = String.fromEnvironment(
    'SOOTHIFY_API_BASE_URL',
    defaultValue: 'https://soothifyafrica.com.ng/api/v1',
  );

  static const _timeout = Duration(seconds: 20);

  /// Uploads get longer: a certificate photographed on a phone is a few
  /// megabytes, and twenty seconds of a Nigerian mobile connection is not
  /// enough to be sure it failed.
  static const _uploadTimeout = Duration(minutes: 2);

  final http.Client _client;
  final String _baseUrl;

  /// Read per request rather than held: an access token lives 30 minutes,
  /// so one captured at startup would be stale by the time it is used.
  final String Function() _accessToken;

  final String Function() _refreshToken;

  /// Called with a fresh pair after a successful refresh, so whoever owns
  /// storage writes them. The client itself keeps nothing.
  final Future<void> Function(String access, String refresh)? _onTokens;

  /// Called when the refresh token is itself dead. The session is over and
  /// the app has to say so; this client cannot decide what that looks like.
  final Future<void> Function()? _onSignedOut;

  /// One refresh at a time. Six screens loading at once all meet the same
  /// expired token, and six parallel refreshes would rotate the refresh
  /// token six times -- five of them landing on a token already replaced.
  Future<bool>? _refreshing;

  Future<Map<String, dynamic>> get(String path) => _send('GET', path, null);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic> body = const {},
  }) => _send('POST', path, body);

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic> body = const {},
  }) => _send('PUT', path, body);

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic> body = const {},
  }) => _send('PATCH', path, body);

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic> body = const {},
  }) => _send('DELETE', path, body);

  /// A list endpoint, however the server chose to answer.
  ///
  /// DRF sends a bare array from an unpaginated view and
  /// `{"results": [...], "count": n}` from a paginated one. Both are normal,
  /// and no caller should have to know which it is dealing with.
  Future<List<Map<String, dynamic>>> getList(String path) async {
    final body = await get(path);
    final rows = body['results'] ?? body['data'] ?? body['items'];
    if (rows is! List) return const [];
    return rows.whereType<Map<String, dynamic>>().toList();
  }

  /// A multipart POST: text fields, and files read from disk.
  ///
  /// Separate from [post] because a file cannot travel as JSON, and because
  /// multipart is the only shape Django's upload handling accepts. Lists go
  /// in [listFields] and are sent comma-joined, which is what the server
  /// splits them from -- there is no nesting in a multipart form.
  ///
  /// Retries once on an expired token like every other call, which means the
  /// files are read again rather than held in memory between attempts.
  Future<Map<String, dynamic>> upload(
    String path, {
    Map<String, String> fields = const {},
    Map<String, List<String>> listFields = const {},
    Map<String, String> files = const {},
    String method = 'POST',
    bool allowRetry = true,
  }) async {
    final response = await _rawUpload(method, path, fields, listFields, files);

    if (response.statusCode == 401 && allowRetry && _refreshToken().isNotEmpty) {
      if (await _refresh()) {
        return upload(
          path,
          fields: fields,
          listFields: listFields,
          files: files,
          method: method,
          allowRetry: false,
        );
      }
    }
    return _decode(response);
  }

  Future<http.Response> _rawUpload(
    String method,
    String path,
    Map<String, String> fields,
    Map<String, List<String>> listFields,
    Map<String, String> files,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final token = _accessToken();
    final request = http.MultipartRequest(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      })
      ..fields.addAll(fields);

    // Joined with commas, and the server splits them.
    //
    // A repeated key would be the usual way to carry a list, but this
    // package models fields as a Map and can only repeat one by adding a
    // *file* part -- which Django files under request.FILES, where
    // `getlist` on the form data will never find it. That mistake reads as
    // "this field is required" from a form that plainly sent it.
    for (final entry in listFields.entries) {
      if (entry.value.isEmpty) continue;
      request.fields[entry.key] = entry.value.join(',');
    }

    for (final entry in files.entries) {
      if (entry.value.isEmpty) continue;
      request.files.add(
        await http.MultipartFile.fromPath(entry.key, entry.value),
      );
    }

    try {
      final streamed = await _client.send(request).timeout(_uploadTimeout);
      return await http.Response.fromStream(streamed);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on async.TimeoutException {
      throw const TimeoutException();
    }
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path,
    Map<String, dynamic>? body, {
    bool allowRetry = true,
  }) async {
    final response = await _raw(method, path, body);

    // An expired access token is the ordinary case, not a failure: they last
    // thirty minutes. Refresh once, quietly, and send the request again. If
    // the refresh also fails the session really is over and the exception
    // from _decode stands.
    if (response.statusCode == 401 && allowRetry && _refreshToken().isNotEmpty) {
      if (await _refresh()) {
        return _send(method, path, body, allowRetry: false);
      }
    }

    return _decode(response);
  }

  Future<http.Response> _raw(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final token = _accessToken();
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      });
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamed = await _client.send(request).timeout(_timeout);
      return await http.Response.fromStream(streamed);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on async.TimeoutException {
      throw const TimeoutException();
    }
  }

  /// Exchange the refresh token for a new pair. True if the session lives.
  ///
  /// Shared: callers that arrive while one is in flight wait on the same
  /// future rather than starting their own.
  Future<bool> _refresh() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refresh = _refreshToken();
    if (refresh.isEmpty) return false;

    http.Response response;
    try {
      response = await _raw('POST', '/auth/token/refresh/', {'refresh': refresh});
    } on AppException {
      // Offline. Not a dead session -- say nothing and let the original
      // request fail with its own network error.
      return false;
    }

    if (response.statusCode != 200) {
      Log.d('Refresh refused (${response.statusCode}); signing out.');
      await _onSignedOut?.call();
      return false;
    }

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final access = '${body['access'] ?? ''}';
      if (access.isEmpty) return false;
      // ROTATE_REFRESH_TOKENS is on server-side, so a new refresh usually
      // comes back too; keep the old one when it does not.
      final rotated = '${body['refresh'] ?? ''}';
      await _onTokens?.call(access, rotated.isEmpty ? refresh : rotated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) {
      if (response.body.isEmpty) return const {};
      final decoded = jsonDecode(response.body);
      // A list body is valid JSON but not what any of these endpoints
      // return; wrapping keeps the signature honest rather than crashing on
      // a cast.
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    }

    Log.d('API $code ${response.request?.url.path}: ${response.body}');
    throw switch (code) {
      400 => _validation(response.body),
      401 || 403 => const UnauthorizedException(),
      404 => const NotFoundException(),
      >= 500 => const ServerException(),
      _ => const UnknownException(),
    };
  }

  /// DRF writes `{"field": ["msg", ...]}`, and sometimes
  /// `{"detail": "msg"}`. Both become a [ValidationException] carrying the
  /// per-field messages, so a form can mark its own fields.
  ValidationException _validation(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final fields = <String, List<String>>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        fields[entry.key] = value is List
            ? value.map((v) => '$v').toList()
            : ['$value'];
      }
      final first = fields.values
          .firstWhere((m) => m.isNotEmpty, orElse: () => const [])
          .firstOrNull;
      return ValidationException(
        first ?? 'Please check what you entered.',
        fieldErrors: fields,
      );
    } catch (_) {
      return const ValidationException('Please check what you entered.');
    }
  }

  void close() => _client.close();
}
