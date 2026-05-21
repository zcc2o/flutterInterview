class ApiResult {
  final int statusCode;
  final dynamic data;

  const ApiResult(this.statusCode, this.data);

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
