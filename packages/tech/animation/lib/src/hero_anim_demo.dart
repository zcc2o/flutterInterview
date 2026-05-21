import 'package:flutter/material.dart';
import '../screens/hero_detail_screen.dart';

class HeroAnimDemo extends StatelessWidget {
  const HeroAnimDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _HeroTile(
          tag: 'hero-blue',
          color: Colors.blue,
          shape: BoxShape.circle,
          icon: Icons.ac_unit,
          label: '圆形',
          onTap: () => _navigate(context, 'hero-blue', Colors.blue, BoxShape.circle),
        ),
        _HeroTile(
          tag: 'hero-green',
          color: Colors.green,
          shape: BoxShape.rectangle,
          icon: Icons.eco,
          label: '矩形',
          onTap: () => _navigate(context, 'hero-green', Colors.green, BoxShape.rectangle),
        ),
        _HeroTile(
          tag: 'hero-orange',
          color: Colors.deepOrange,
          shape: BoxShape.circle,
          icon: Icons.local_fire_department,
          label: '火焰',
          onTap: () => _navigate(
            context,
            'hero-orange',
            Colors.deepOrange,
            BoxShape.circle,
          ),
        ),
      ],
    );
  }

  void _navigate(
    BuildContext context,
    String tag,
    Color color,
    BoxShape shape,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HeroDetailScreen(tag: tag, color: color, shape: shape),
      ),
    );
  }
}

class _HeroTile extends StatelessWidget {
  final String tag;
  final Color color;
  final BoxShape shape;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeroTile({
    required this.tag,
    required this.color,
    required this.shape,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Hero(
            tag: tag,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: color, shape: shape),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
