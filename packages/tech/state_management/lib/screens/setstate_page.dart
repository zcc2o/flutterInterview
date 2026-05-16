import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../models/product.dart';

class SetStatePage extends StatefulWidget {
  const SetStatePage({super.key});

  @override
  State<SetStatePage> createState() => _SetStatePageState();
}

class _SetStatePageState extends State<SetStatePage> {
  // ---- 商品数据 ----
  final _products = kProducts;
  String _selectedCategory = '全部';

  // ---- 购物车 ----
  final _cartItems = <CartItem>[];

  // ---- 订单历史 ----
  final _orders = <Order>[];

  // ---- 搜索 ----
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<Product> get _filteredProducts {
    var list = _products;
    if (_selectedCategory != '全部') {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) => p.name.contains(_searchQuery)).toList();
    }
    return list;
  }

  double get _subtotal =>
      _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  double get _tax => _subtotal * kTaxRate;

  double get _total => _subtotal + _tax;

  int get _cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void _addToCart(Product product) {
    setState(() {
      final idx = _cartItems.indexWhere((c) => c.product.id == product.id);
      if (idx >= 0) {
        _cartItems[idx].quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cartItems.removeWhere((c) => c.product.id == product.id);
    });
  }

  void _checkout() {
    if (_cartItems.isEmpty) return;
    setState(() {
      _orders.insert(
        0,
        Order(
          items: List.from(_cartItems),
          total: _total,
          createdAt: DateTime.now(),
        ),
      );
      _cartItems.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return TechDetailShell(
      title: 'setState — 所有状态在 Widget 内',
      child: Column(
        children: [
          // 购物车状态栏
          Container(
            color: Colors.red.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart),
                const SizedBox(width: 8),
                Text('$_cartCount 件'),
                const Spacer(),
                Text('¥${_total.toStringAsFixed(2)}'),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _cartItems.isEmpty ? null : _checkout,
                  child: const Text('结算'),
                ),
              ],
            ),
          ),
          // 搜索 + 分类筛选
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '搜索商品…',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
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
                      selected: _selectedCategory == kCategories[i],
                      onSelected: (_) =>
                          setState(() => _selectedCategory = kCategories[i]),
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
                final inCart = _cartItems.any((c) => c.product.id == p.id);
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.category}  ·  ¥${p.price.toStringAsFixed(2)}',
                  ),
                  trailing: inCart
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () => _removeFromCart(p),
                            ),
                            Text(
                              '${_cartItems.firstWhere((c) => c.product.id == p.id).quantity}',
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              onPressed: () => _addToCart(p),
                            ),
                          ],
                        )
                      : FilledButton(
                          onPressed: () => _addToCart(p),
                          child: const Text('加入'),
                        ),
                );
              },
            ),
          ),
          // 购物车明细
          if (_cartItems.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Text(
                          '购物车明细',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const Spacer(),
                        Expanded(
                          child: Text(
                            '小计 ¥$_subtotal  |  税 ¥${_tax.toStringAsFixed(2)}  |  合计 ¥${_total.toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: _cartItems
                          .map(
                            (c) => ListTile(
                              dense: true,
                              title: Text(c.product.name),
                              trailing: Text(
                                '×${c.quantity}  ¥${c.subtotal.toStringAsFixed(2)}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          // 订单历史
          if (_orders.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '订单历史',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: _orders
                          .map(
                            (o) => ListTile(
                              dense: true,
                              title: Text(
                                '${o.createdAt.toString().substring(0, 19)}',
                              ),
                              trailing: Text(
                                '¥${o.total.toStringAsFixed(2)}  (${o.items.length}件)',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
