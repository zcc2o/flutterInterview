import 'package:flutter/material.dart';

class ExplicitAnimDemo extends StatefulWidget {
  const ExplicitAnimDemo({super.key});

  @override
  State<ExplicitAnimDemo> createState() => _ExplicitAnimDemoState();
}

class _ExplicitAnimDemoState extends State<ExplicitAnimDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _running = !_running;
      _running ? _ctrl.repeat() : _ctrl.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.5, end: 1.5).animate(
                CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
              ),
              child: const _AnimBox(color: Colors.teal, icon: Icons.aspect_ratio),
            ),
            RotationTransition(
              turns: _ctrl,
              child: const _AnimBox(color: Colors.purple, icon: Icons.rotate_right),
            ),
            SlideTransition(
              position: Tween(begin: const Offset(-0.5, 0), end: const Offset(0.5, 0))
                  .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)),
              child: const _AnimBox(color: Colors.deepOrange, icon: Icons.swap_horiz),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.tonal(
          onPressed: _toggle,
          child: Text(_running ? '暂停' : '播放'),
        ),
      ],
    );
  }
}

class _AnimBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _AnimBox({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: Colors.white),
    );
  }
}
