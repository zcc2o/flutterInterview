import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../models/product.dart';

// ---------- ChangeNotifier Models ----------

class CartModel extends ChangeNotifier {
  final _items = <CartItem>[];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold(0, (s, c) => s + c.quantity);
  double get subtotal => _items.fold(0, (s, c) => s + c.subtotal);
  double get tax => subtotal * kTaxRate;
  double get total => subtotal + tax;

  void add(Product product) {
    final idx = _items.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void remove(Product product) {
    _items.removeWhere((c) => c.product.id == product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class FilterModel extends ChangeNotifier {
  String _category = '全部';
  String _query = '';

  String get category => _category;
  String get query => _query;

  void setCategory(String v) {
    _category = v;
    notifyListeners();
  }

  void setQuery(String v) {
    _query = v;
    notifyListeners();
  }

  List<Product> apply(List<Product> products) {
    var list = products;
    if (_category != '全部') {
      list = list.where((p) => p.category == _category).toList();
    }
    if (_query.isNotEmpty) {
      list = list.where((p) => p.name.contains(_query)).toList();
    }
    return list;
  }
}

class OrderModel extends ChangeNotifier {
  final _orders = <Order>[];
  List<Order> get orders => List.unmodifiable(_orders);

  void add(CartModel cart) {
    if (cart.items.isEmpty) return;
    _orders.insert(0, Order(items: List.from(cart.items), total: cart.total, createdAt: DateTime.now()));
    cart.clear();
    notifyListeners();
  }
}

// ---------- 页面 ----------

class ChangeNotifierPage extends StatefulWidget {
  const ChangeNotifierPage({super.key});

  @override
  State<ChangeNotifierPage> createState() => _ChangeNotifierPageState();
}

class _ChangeNotifierPageState extends State<ChangeNotifierPage> {
  final _cart = CartModel();
  final _filter = FilterModel();
  final _orders = OrderModel();

  @override
  void dispose() {
    // ChangeNotifier 需要手动 dispose
    _cart.dispose();
    _filter.dispose();
    _orders.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: 'ChangeNotifier — Model 解耦',
      child: Column(
        children: [
          // 状态栏 - 分别监听各自 Model
          ListenableBuilder(
            listenable: _cart,
            builder: (_, __) => Container(
              color: Colors.orange.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart),
                  const SizedBox(width: 8),
                  Text('${_cart.count} 件'),
                  const Spacer(),
                  Text('¥${_cart.total.toStringAsFixed(2)}'),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _cart.items.isEmpty ? null : () => _orders.add(_cart),
                    child: const Text('结算'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: '搜索…', prefixIcon: Icon(Icons.search), isDense: true),
                  onChanged: _filter.setQuery,
                ),
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: _filter,
                  builder: (_, __) => SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => ChoiceChip(
                        label: Text(kCategories[i]),
                        selected: _filter.category == kCategories[i],
                        onSelected: (v) => v ? _filter.setCategory(kCategories[i]) : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 商品列表 - 监听商品和购物车
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([_filter, _cart]),
              builder: (_, __) {
                final filtered = _filter.apply(kProducts);
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    final inCart = _cart.items.any((c) => c.product.id == p.id);
                    final qty = inCart ? _cart.items.firstWhere((c) => c.product.id == p.id).quantity : 0;
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text('${p.category}  ·  ¥${p.price.toStringAsFixed(2)}'),
                      trailing: inCart
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.remove_circle), onPressed: () => _cart.remove(p)),
                                Text('$qty'),
                                IconButton(icon: const Icon(Icons.add_circle), onPressed: () => _cart.add(p)),
                              ],
                            )
                          : FilledButton(onPressed: () => _cart.add(p), child: const Text('加入')),
                    );
                  },
                );
              },
            ),
          ),
          // 购物车明细
          ListenableBuilder(
            listenable: _cart,
            builder: (_, __) {
              if (_cart.items.isEmpty) return const SizedBox.shrink();
              return Container(
                constraints: const BoxConstraints(maxHeight: 200),
                color: Colors.grey.shade100,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Text('购物车明细', style: Theme.of(context).textTheme.titleSmall),
                          const Spacer(),
                          Expanded(
                            child: Text(
                              '小计 ¥${_cart.subtotal.toStringAsFixed(2)}  |  税 ¥${_cart.tax.toStringAsFixed(2)}  |  合计 ¥${_cart.total.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: _cart.items
                            .map((c) => ListTile(
                                  dense: true,
                                  title: Text(c.product.name),
                                  trailing: Text('×${c.quantity}  ¥${c.subtotal.toStringAsFixed(2)}'),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // 订单历史
          ListenableBuilder(
            listenable: _orders,
            builder: (_, __) {
              if (_orders.orders.isEmpty) return const SizedBox.shrink();
              return Container(
                constraints: const BoxConstraints(maxHeight: 120),
                color: Colors.blue.shade50,
                child: ListView(
                  children: _orders.orders.map((o) => ListTile(
                        dense: true,
                        title: Text('${o.createdAt.toString().substring(0, 19)}'),
                        trailing: Text('¥${o.total.toStringAsFixed(2)} (${o.items.length}件)'),
                      )).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
