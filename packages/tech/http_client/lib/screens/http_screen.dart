import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../src/http_client.dart';
import '../src/api_result.dart';
import '../src/http_request.dart';

class HttpScreen extends StatefulWidget {
  const HttpScreen({super.key});

  @override
  State<HttpScreen> createState() => _HttpScreenState();
}

class _HttpScreenState extends State<HttpScreen> {
  final _client = HttpClient(baseUrl: 'https://jsonplaceholder.typicode.com');
  String _response = '';
  bool _loading = false;

  Future<void> _doGet() async {
    setState(() => _loading = true);
    final request = HttpRequest.get('/posts/1');
    final result = await _client.execute(request);
    _showResult('GET /posts/1', result);
  }

  Future<void> _doPost() async {
    setState(() => _loading = true);
    final request = HttpRequest.post('/posts', body: {
      'title': 'Flutter HTTP',
      'body': '自定义 HttpClient 封装',
      'userId': 1,
    });
    final result = await _client.execute(request);
    _showResult('POST /posts', result);
  }

  void _showResult(String title, ApiResult result) {
    setState(() {
      _loading = false;
      _response = '$title\n'
          'Status: ${result.statusCode}\n'
          'Data: ${const JsonEncoder.withIndent('  ').convert(result.data)}';
    });
  }

  @override
  void dispose() {
    _client.dispose();
    super.dispose();
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
                      '2. HttpRequest 统一封装请求参数\n'
                      '3. 超时处理（timeout + TimeoutException）\n'
                      '4. 状态码检查（isSuccess）\n'
                      '5. Token 管理（setToken）\n'
                      '6. 错误统一封装（ApiResult）\n'
                      '7. 支持 GET / POST / PUT / DELETE / PATCH'),
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
