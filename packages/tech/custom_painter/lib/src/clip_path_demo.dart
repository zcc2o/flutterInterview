import 'dart:math';
import 'package:flutter/material.dart';

class ClipPathDemo extends StatelessWidget {
  const ClipPathDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            width: 140,
            height: 100,
            color: Colors.teal,
            child: const Center(child: Text('波浪裁剪', style: TextStyle(color: Colors.white))),
          ),
        ),
        ClipPath(
          clipper: _StarClipper(),
          child: Container(
            width: 140,
            height: 100,
            color: Colors.deepOrange,
            child: const Center(child: Text('星形裁剪', style: TextStyle(color: Colors.white))),
          ),
        ),
        ClipPath(
          clipper: _TriangleClipper(),
          child: Container(
            width: 140,
            height: 100,
            color: Colors.indigo,
            child: const Center(child: Text('三角裁剪', style: TextStyle(color: Colors.white))),
          ),
        ),
      ],
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.3, size.width * 0.5, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.75, size.height * 1.1, size.width, size.height * 0.4)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _StarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = min(cx, cy);
    final innerR = outerR * 0.4;
    const points = 5;
    for (int i = 0; i < points * 2; i++) {
      final angle = i * pi / points - pi / 2;
      final r = i.isEven ? outerR : innerR;
      final x = cx + cos(angle) * r;
      final y = cy + sin(angle) * r;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
