import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../models/product.dart';

// ---------- InheritedWidget 定义 ----------

class _CartScope extends InheritedWidget {
  final List<CartItem> items;
  final void Function(Product) onAdd;
  final void Function(Product) onRemove;
  final VoidCallback onCheckout;

  const _CartScope({
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.onCheckout,
    required super.child,
  });

  static _CartScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CartScope>()!;

  @override
  bool updateShouldNotify(_CartScope old) => items != old.items;
}

class _FilterScope extends InheritedWidget {
  final String category;
  final String query;
  final void Function(String) onCategoryChanged;
  final void Function(String) onQueryChanged;

  const _FilterScope({
    required this.category,
    required this.query,
    required this.onCategoryChanged,
    required this.onQueryChanged,
    required super.child,
  });

  static _FilterScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_FilterScope>()!;

  @override
  bool updateShouldNotify(_FilterScope old) =>
      category != old.category || query != old.query;
}

class _OrderScope extends InheritedWidget {
  final List<Order> orders;

  const _OrderScope({required this.orders, required super.child});

  static _OrderScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_OrderScope>()!;

  @override
  bool updateShouldNotify(_OrderScope old) => orders != old.orders;
}

// ---------- 页面 ----------

class InheritedPage extends StatefulWidget {
  const InheritedPage({super.key});

  @override
  State<InheritedPage> createState() => _InheritedPageState();
}

class _InheritedPageState extends State<InheritedPage> {
  // StatefulWidget 仍然需要来持有可变数据
  List<CartItem> _cartItems = [];
  List<Order> _orders = [];
  String _selectedCategory = '全部';
  String _searchQuery = '';

  double get _total =>
      _cartItems.fold(0.0, (s, c) => s + c.subtotal) * (1 + kTaxRate);

  void _addToCart(Product product) {
    setState(() {
      final idx = _cartItems.indexWhere((c) => c.product.id == product.id);
      if (idx >= 0) {
        _cartItems = [
          for (int i = 0; i < _cartItems.length; i++)
            if (i == idx)
              CartItem(product: _cartItems[i].product, quantity: _cartItems[i].quantity + 1)
            else
              _cartItems[i],
        ];
      } else {
        _cartItems = [..._cartItems, CartItem(product: product)];
      }
    });
  }

  void _removeFromCart(Product product) {
    setState(() => _cartItems = _cartItems.where((c) => c.product.id != product.id).toList());
  }

  void _checkout() {
    if (_cartItems.isEmpty) return;
    setState(() {
      _orders = [Order(items: List.from(_cartItems), total: _total, createdAt: DateTime.now()), ..._orders];
      _cartItems = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // 三层 InheritedWidget 嵌套
    return _OrderScope(
      orders: _orders,
      child: _FilterScope(
        category: _selectedCategory,
        query: _searchQuery,
        onCategoryChanged: (v) => setState(() => _selectedCategory = v),
        onQueryChanged: (v) => setState(() => _searchQuery = v),
        child: _CartScope(
          items: _cartItems,
          onAdd: _addToCart,
          onRemove: _removeFromCart,
          onCheckout: _checkout,
          child: const TechDetailShell(
            title: 'InheritedWidget — 跨组件依赖注入',
            child: _Body(),
          ),
        ),
      ),
    );
  }
}

// ---------- 子组件（可任意拆分，通过 InheritedWidget 访问状态） ----------

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final cart = _CartScope.of(context);
    final filter = _FilterScope.of(context);
    final orders = _OrderScope.of(context);
    final cartCount = cart.items.fold<int>(0, (s, c) => s + c.quantity);
    final subtotal = cart.items.fold<double>(0, (s, c) => s + c.subtotal);
    final tax = subtotal * kTaxRate;
    final total = subtotal + tax;

    var filtered = kProducts;
    if (filter.category != '全部') {
      filtered = filtered.where((p) => p.category == filter.category).toList();
    }
    if (filter.query.isNotEmpty) {
      filtered = filtered.where((p) => p.name.contains(filter.query)).toList();
    }

    return Column(
      children: [
        // 购物车状态栏
        Container(
          color: Colors.blue.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart),
              const SizedBox(width: 8),
              Text('$cartCount 件'),
              const Spacer(),
              Text('¥${total.toStringAsFixed(2)}'),
              const SizedBox(width: 12),
              FilledButton(onPressed: cart.items.isEmpty ? null : cart.onCheckout, child: const Text('结算')),
            ],
          ),
        ),
        // 搜索 + 分类
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(hintText: '搜索…', prefixIcon: Icon(Icons.search), isDense: true),
                onChanged: filter.onQueryChanged,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ChoiceChip(
                    label: Text(kCategories[i]),
                    selected: filter.category == kCategories[i],
                    onSelected: (_) => filter.onCategoryChanged(kCategories[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 商品列表
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = filtered[i];
              final cartItem = cart.items.cast<CartItem?>().firstWhere((c) => c?.product.id == p.id, orElse: () => null);
              return ListTile(
                title: Text(p.name),
                subtitle: Text('${p.category}  ·  ¥${p.price.toStringAsFixed(2)}'),
                trailing: cartItem != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.remove_circle), onPressed: () => cart.onRemove(p)),
                          Text('${cartItem.quantity}'),
                          IconButton(icon: const Icon(Icons.add_circle), onPressed: () => cart.onAdd(p)),
                        ],
                      )
                    : FilledButton(onPressed: () => cart.onAdd(p), child: const Text('加入')),
              );
            },
          ),
        ),
        // 购物车明细
        if (cart.items.isNotEmpty)
          Container(
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
                          '小计 ¥${subtotal.toStringAsFixed(2)}  |  税 ¥${tax.toStringAsFixed(2)}  |  合计 ¥${total.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: cart.items
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
          ),
        // 订单历史
        if (orders.orders.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            color: Colors.blue.shade50,
            child: ListView(
              children: orders.orders.map((o) => ListTile(
                    dense: true,
                    title: Text('${o.createdAt.toString().substring(0, 19)}'),
                    trailing: Text('¥${o.total.toStringAsFixed(2)} (${o.items.length}件)'),
                  )).toList(),
            ),
          ),
      ],
    );
  }
}
