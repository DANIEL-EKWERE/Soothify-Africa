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
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? defaultBaseUrl,
       _accessToken = accessToken ?? (() => '');

  /// Overridable at build time so a debug build can point at a laptop:
  ///
  ///   flutter run --dart-define=SOOTHIFY_API_BASE_URL=http://10.0.2.2:8000/api/v1
  ///
  /// The default is the AWS subdomain the backend's own settings name for
  /// the mobile API; the cPanel site serves the same paths off the apex.
  static const defaultBaseUrl = String.fromEnvironment(
    'SOOTHIFY_API_BASE_URL',
    defaultValue: 'https://api.soothifyafrica.com.ng/api/v1',
  );

  static const _timeout = Duration(seconds: 20);

  final http.Client _client;
  final String _baseUrl;

  /// Read per request rather than held: an access token lives 30 minutes,
  /// so one captured at startup would be stale by the time it is used.
  final String Function() _accessToken;

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic> body = const {},
  }) => _send('POST', path, body);

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic> body = const {},
  }) => _send('DELETE', path, body);

  Future<Map<String, dynamic>> _send(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final token = _accessToken();
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      })
      ..body = jsonEncode(body);

    http.Response response;
    try {
      final streamed = await _client.send(request).timeout(_timeout);
      response = await http.Response.fromStream(streamed);
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on async.TimeoutException {
      throw const TimeoutException();
    }

    return _decode(response);
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
