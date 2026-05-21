import 'package:flutter/material.dart';

class StaggeredAnimDemo extends StatefulWidget {
  const StaggeredAnimDemo({super.key});

  @override
  State<StaggeredAnimDemo> createState() => _StaggeredAnimDemoState();
}

class _StaggeredAnimDemoState extends State<StaggeredAnimDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _width;
  late final Animation<double> _slide;
  bool _forward = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );
    _width = Tween(begin: 50.0, end: 260.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.6, curve: Curves.easeInOut)),
    );
    _slide = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _run() {
    setState(() => _forward = !_forward);
    _forward ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Opacity(
                opacity: _opacity.value,
                child: Container(
                  width: _width.value,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Positioned(
                        left: 12 + (1 - _slide.value) * 100,
                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
                      ),
                      const Center(child: Text('Staggered', style: TextStyle(color: Colors.white, fontSize: 18))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.tonal(onPressed: _run, child: const Text('播放交错动画')),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: () => _ctrl.reset(), child: const Text('重置')),
          ],
        ),
      ],
    );
  }
}
