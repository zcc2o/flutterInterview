import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_result.dart';
import 'http_request.dart';

class HttpClient {
  final http.Client _client = http.Client();
  final String baseUrl;
  final Duration defaultTimeout;
  String? _authToken;

  HttpClient({
    required this.baseUrl,
    this.defaultTimeout = const Duration(seconds: 10),
  });

  void setToken(String token) => _authToken = token;

  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<ApiResult> execute(HttpRequest request) async {
    try {
      final uri = Uri.parse(
        '$baseUrl${request.path}',
      ).replace(queryParameters: request.queryParameters);
      final headers = {..._defaultHeaders, ...?request.headers};
      final timeout = request.timeout ?? defaultTimeout;

      final resp = await _send(uri, headers, request, timeout);
      return ApiResult(resp.statusCode, jsonDecode(resp.body));
    } on TimeoutException {
      return const ApiResult(408, {'error': '请求超时'});
    } catch (e) {
      return ApiResult(500, {'error': e.toString()});
    }
  }

  Future<http.Response> _send(
    Uri uri,
    Map<String, String> headers,
    HttpRequest request,
    Duration timeout,
  ) {
    return switch (request.method) {
      HttpMethod.get => _client.get(uri, headers: headers).timeout(timeout),
      HttpMethod.post =>
        _client
            .post(uri, headers: headers, body: jsonEncode(request.body))
            .timeout(timeout),
      HttpMethod.put =>
        _client
            .put(uri, headers: headers, body: jsonEncode(request.body))
            .timeout(timeout),
      HttpMethod.delete =>
        _client.delete(uri, headers: headers).timeout(timeout),
      HttpMethod.patch =>
        _client
            .patch(uri, headers: headers, body: jsonEncode(request.body))
            .timeout(timeout),
    };
  }

  Future<ApiResult> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) => execute(
    HttpRequest.get(path, queryParameters: queryParameters, headers: headers),
  );

  Future<ApiResult> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) => execute(HttpRequest.post(path, body: body, headers: headers));

  Future<ApiResult> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) => execute(HttpRequest.put(path, body: body, headers: headers));

  Future<ApiResult> delete(String path, {Map<String, String>? headers}) =>
      execute(HttpRequest.delete(path, headers: headers));

  Future<ApiResult> patch(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) => execute(HttpRequest.patch(path, body: body, headers: headers));

  void dispose() => _client.close();
}
