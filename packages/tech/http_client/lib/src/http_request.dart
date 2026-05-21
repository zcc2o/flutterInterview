/// HTTP 请求方法枚举
enum HttpMethod { get, post, put, delete, patch }

/// 封装一次 HTTP 请求的所有配置
class HttpRequest {
  final HttpMethod method;
  final String path;
  final Map<String, String>? queryParameters;
  final Object? body;
  final Map<String, String>? headers;
  final Duration? timeout;

  const HttpRequest({
    required this.method,
    required this.path,
    this.queryParameters,
    this.body,
    this.headers,
    this.timeout,
  });

  factory HttpRequest.get(String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) => HttpRequest(
    method: HttpMethod.get,
    path: path,
    queryParameters: queryParameters,
    headers: headers,
    timeout: timeout,
  );

  factory HttpRequest.post(String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) => HttpRequest(
    method: HttpMethod.post,
    path: path,
    body: body,
    queryParameters: queryParameters,
    headers: headers,
    timeout: timeout,
  );

  factory HttpRequest.put(String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) => HttpRequest(
    method: HttpMethod.put,
    path: path,
    body: body,
    queryParameters: queryParameters,
    headers: headers,
    timeout: timeout,
  );

  factory HttpRequest.delete(String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) => HttpRequest(
    method: HttpMethod.delete,
    path: path,
    queryParameters: queryParameters,
    headers: headers,
    timeout: timeout,
  );

  factory HttpRequest.patch(String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) => HttpRequest(
    method: HttpMethod.patch,
    path: path,
    body: body,
    queryParameters: queryParameters,
    headers: headers,
    timeout: timeout,
  );
}
