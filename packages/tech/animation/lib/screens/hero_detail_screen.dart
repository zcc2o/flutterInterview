import 'package:flutter/material.dart';

class HeroDetailScreen extends StatelessWidget {
  final String tag;
  final Color color;
  final BoxShape shape;

  const HeroDetailScreen({
    super.key,
    required this.tag,
    required this.color,
    required this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hero 详情 — $tag')),
      body: Center(
        child: Hero(
          tag: tag,
          child: Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: shape),
            child: const Text(
              '测试',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            // const Icon(Icons.ice_skating, color: Colors.white, size: 80),
          ),
        ),
      ),
    );
  }
}
