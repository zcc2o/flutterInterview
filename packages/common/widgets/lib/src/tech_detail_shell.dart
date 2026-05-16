import 'package:flutter/material.dart';

class TechDetailShell extends StatelessWidget {
  final String title;
  final Widget child;

  const TechDetailShell({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: child),
    );
  }
}
