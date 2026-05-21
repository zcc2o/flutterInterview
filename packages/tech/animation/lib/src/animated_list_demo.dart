import 'package:flutter/material.dart';

class AnimatedListDemo extends StatefulWidget {
  const AnimatedListDemo({super.key});

  @override
  State<AnimatedListDemo> createState() => _AnimatedListDemoState();
}

class _AnimatedListDemoState extends State<AnimatedListDemo> {
  final _items = <_Item>[
    _Item(icon: Icons.star, label: 'Star', color: Colors.amber),
    _Item(icon: Icons.favorite, label: 'Heart', color: Colors.red),
    _Item(icon: Icons.thumb_up, label: 'Like', color: Colors.blue),
  ];
  final _key = GlobalKey<AnimatedListState>();
  int _nextId = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: AnimatedList(
            key: _key,
            initialItemCount: _items.length,
            itemBuilder: (context, i, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Icon(_items[i].icon, color: _items[i].color),
                    title: Text(_items[i].label),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeAt(i),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.tonal(
              onPressed: _add,
              child: const Text('添加'),
            ),
          ],
        ),
      ],
    );
  }

  void _add() {
    final item = _Item(
      icon: Icons.extension,
      label: 'Item $_nextId',
      color: Colors.teal,
    );
    _nextId++;
    _items.add(item);
    _key.currentState?.insertItem(_items.length - 1);
  }

  void _removeAt(int i) {
    final removed = _items.removeAt(i);
    _key.currentState?.removeItem(
      i,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Icon(removed.icon, color: removed.color),
            title: Text(removed.label),
          ),
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final Color color;
  _Item({required this.icon, required this.label, required this.color});
}
