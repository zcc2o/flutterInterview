import 'package:flutter/material.dart';

class ImplicitAnimDemo extends StatefulWidget {
  const ImplicitAnimDemo({super.key});

  @override
  State<ImplicitAnimDemo> createState() => _ImplicitAnimDemoState();
}

class _ImplicitAnimDemoState extends State<ImplicitAnimDemo> {
  bool _toggled = false;

  void _toggle() => setState(() => _toggled = !_toggled);

  @override
  Widget build(BuildContext context) {
    final t = _toggled;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: t ? 80 : 120,
              height: t ? 80 : 120,
              decoration: BoxDecoration(
                color: t ? Colors.teal : Colors.blue,
                borderRadius: BorderRadius.circular(t ? 40 : 8),
                boxShadow: [
                  BoxShadow(
                    color: (t ? Colors.teal : Colors.blue).withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: t ? 1.0 : 0.3,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 40),
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 500),
              style: TextStyle(
                fontSize: t ? 24 : 16,
                color: t ? Colors.red : Colors.grey,
                fontWeight: t ? FontWeight.bold : FontWeight.normal,
              ),
              child: const Text('Flutter'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.tonal(onPressed: _toggle, child: const Text('切换形态')),
      ],
    );
  }
}
