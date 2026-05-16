import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:interview_widgets/interview_widgets.dart';

// ---------- 自定义 HTTP 客户端 ----------
class HttpClient {
  final http.Client _client = http.Client();
  final String baseUrl;
  final Duration timeout;
  String? _authToken;

  HttpClient({required this.baseUrl, this.timeout = const Duration(seconds: 10)});

  void setToken(String token) => _authToken = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<ApiResult> get(String path, {Map<String, String>? query}) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
      final resp = await _client.get(uri, headers: _headers).timeout(timeout);
      return ApiResult(resp.statusCode, jsonDecode(resp.body));
    } on TimeoutException {
      return ApiResult(408, {'error': '请求超时'});
    } catch (e) {
      return ApiResult(500, {'error': e.toString()});
    }
  }

  Future<ApiResult> post(String path, {Object? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final resp = await _client
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(timeout);
      return ApiResult(resp.statusCode, jsonDecode(resp.body));
    } on TimeoutException {
      return ApiResult(408, {'error': '请求超时'});
    } catch (e) {
      return ApiResult(500, {'error': e.toString()});
    }
  }

  void dispose() => _client.close();
}

class ApiResult {
  final int statusCode;
  final dynamic data;
  const ApiResult(this.statusCode, this.data);

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class HttpScreen extends StatefulWidget {
  const HttpScreen({super.key});

  @override
  State<HttpScreen> createState() => _HttpScreenState();
}

class _HttpScreenState extends State<HttpScreen> {
  String _response = '';
  bool _loading = false;

  Future<void> _doGet() async {
    setState(() => _loading = true);
    final client = HttpClient(baseUrl: 'https://jsonplaceholder.typicode.com');
    final result = await client.get('/posts/1');
    setState(() {
      _loading = false;
      _response = 'GET /posts/1\n'
          'Status: ${result.statusCode}\n'
          'Data: ${const JsonEncoder.withIndent('  ').convert(result.data)}';
    });
    client.dispose();
  }

  Future<void> _doPost() async {
    setState(() => _loading = true);
    final client = HttpClient(baseUrl: 'https://jsonplaceholder.typicode.com');
    final result = await client.post('/posts', body: {
      'title': 'Flutter HTTP',
      'body': '自定义 HttpClient 封装',
      'userId': 1,
    });
    setState(() {
      _loading = false;
      _response = 'POST /posts\n'
          'Status: ${result.statusCode}\n'
          'Data: ${const JsonEncoder.withIndent('  ').convert(result.data)}';
    });
    client.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: '网络请求封装',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('HTTP Client 封装要点', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const Text('1. 统一 Base URL + 请求头\n'
                      '2. 超时处理（timeout + TimeoutException）\n'
                      '3. 状态码检查（isSuccess）\n'
                      '4. Token 管理（setToken）\n'
                      '5. 请求/响应拦截（日志、重试）\n'
                      '6. 错误统一封装（ApiResult）'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _loading ? null : _doGet,
                icon: const Icon(Icons.download),
                label: const Text('GET 请求'),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: _loading ? null : _doPost,
                icon: const Icon(Icons.upload),
                label: const Text('POST 请求'),
              ),
            ],
          ),
          if (_loading) const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          if (_response.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  _response,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
