import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import 'package:provider/provider.dart';
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
    final idx = _items.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--;
      } else {
        _items.removeWhere((c) => c.product.id == product.id);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int quantityOf(Product product) {
    final idx = _items.indexWhere((c) => c.product.id == product.id);
    return idx >= 0 ? _items[idx].quantity : 0;
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
    _orders.insert(
      0,
      Order(
        items: List.from(cart.items),
        total: cart.total,
        createdAt: DateTime.now(),
      ),
    );
    cart.clear();
    notifyListeners();
  }
}

// ---------- 页面 ----------

class ProviderPage extends StatelessWidget {
  const ProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => FilterModel()),
        ChangeNotifierProvider(create: (_) => OrderModel()),
      ],
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return TechDetailShell(
      title: 'Provider — DI + Consumer / Selector',
      child: Column(
        children: [
          // 状态栏
          Consumer<CartModel>(
            builder: (_, cartttt, __) => Container(
              color: Colors.purple.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart),
                  const SizedBox(width: 8),
                  Text('${cartttt.count} 件'),
                  const Spacer(),
                  Text('¥${cartttt.total.toStringAsFixed(2)}'),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: cartttt.items.isEmpty
                        ? null
                        : () => context.read<OrderModel>().add(cartttt),
                    child: const Text('结算'),
                  ),
                ],
              ),
            ),
          ),
          // 搜索 + 分类
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: '搜索…',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: context.read<FilterModel>().setQuery,
                ),
                const SizedBox(height: 8),
                // Selector: 仅当 category 变化时重建，query 变化不触发
                Selector<FilterModel, String>(
                  selector: (_, m) => m.category,
                  builder: (_, category, __) => SizedBox(
                    height: 60,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: kCategories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) => ChoiceChip(
                              label: Text(kCategories[i]),
                              selected: category == kCategories[i],
                              onSelected: (v) => v
                                  ? context.read<FilterModel>().setCategory(
                                      kCategories[i],
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Text(
                          '当前筛选：$category',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 商品列表
          Expanded(
            child: Consumer<FilterModel>(
              builder: (_, filter, __) {
                final filtered = filter.apply(kProducts);
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    // 当前遍历到的商品
                    final p = filtered[i];
                    return Selector<CartModel, int>(
                      selector: (_, cart) => cart.quantityOf(p),
                      builder: (_, quantity, __) {
                        // 是否在购物车中
                        final inCart = quantity > 0;
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
                                      onPressed: () =>
                                          context.read<CartModel>().remove(p),
                                    ),
                                    Text('$quantity'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      onPressed: () =>
                                          context.read<CartModel>().add(p),
                                    ),
                                  ],
                                )
                              : FilledButton(
                                  onPressed: () =>
                                      context.read<CartModel>().add(p),
                                  child: const Text('加入'),
                                ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // 购物车明细
          Consumer<CartModel>(
            builder: (_, cart, __) {
              if (cart.items.isEmpty) return const SizedBox.shrink();
              return Container(
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
                              '小计 ¥${cart.subtotal.toStringAsFixed(2)}  |  税 ¥${cart.tax.toStringAsFixed(2)}  |  合计 ¥${cart.total.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: cart.items
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
              );
            },
          ),
          // 订单历史
          Consumer<OrderModel>(
            builder: (_, orders, __) {
              if (orders.orders.isEmpty) return const SizedBox.shrink();
              return Container(
                constraints: const BoxConstraints(maxHeight: 120),
                color: Colors.blue.shade50,
                child: ListView(
                  children: orders.orders
                      .map(
                        (o) => ListTile(
                          dense: true,
                          title: Text(
                            '${o.createdAt.toString().substring(0, 19)}',
                          ),
                          trailing: Text(
                            '¥${o.total.toStringAsFixed(2)} (${o.items.length}件)',
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
