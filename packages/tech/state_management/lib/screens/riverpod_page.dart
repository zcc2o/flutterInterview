import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../models/product.dart';

// ---------- Providers ----------

final categoryProvider = StateProvider<String>((ref) => '全部');
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final category = ref.watch(categoryProvider);
  final query = ref.watch(searchQueryProvider);
  var list = kProducts;
  if (category != '全部') {
    list = list.where((p) => p.category == category).toList();
  }
  if (query.isNotEmpty) {
    list = list.where((p) => p.name.contains(query)).toList();
  }
  return list;
});

// NotifierProvider<①Notifier类型, ②数据状态类型>
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Product product) {
    final idx = state.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == idx)
            CartItem(product: state[i].product, quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, CartItem(product: product)];
    }
  }

  // 遍历购物车数据，如果不等于购物车数据 就添加到新的列表中，最后用新的列表替换掉旧的购物车数据
  void remove(Product product) {
    // 应该先找到这个对象然后减到0才删除
    final idx = state.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      final item = state[idx];
      if (item.quantity > 1) {
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == idx)
              CartItem(
                product: state[i].product,
                quantity: state[i].quantity - 1,
              )
            else
              state[i],
        ];
      } else {
        state = state.where((c) => c.product.id != product.id).toList();
      }
    } else {
      state = state.where((c) => c.product.id != product.id).toList();
    }
  }

  void clear() => state = [];
}

// 计算属性：cart 的派生值
// 计算选择的商品总数
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (s, c) => s + c.quantity);
});

// 计算费用不含税
final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (s, c) => s + c.subtotal);
});

// 计算税费
final cartTaxProvider = Provider<double>((ref) {
  return ref.watch(cartSubtotalProvider) * kTaxRate;
});

// 总费用
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartSubtotalProvider) + ref.watch(cartTaxProvider);
});

final orderProvider = NotifierProvider<OrderNotifier, List<Order>>(
  OrderNotifier.new,
);

class OrderNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() => [];

  void checkout(List<CartItem> items, double total) {
    state = [
      Order(items: List.from(items), total: total, createdAt: DateTime.now()),
      ...state,
    ];
  }
}

// ---------- 页面 ----------
class RiverpodPage extends ConsumerWidget {
  const RiverpodPage({super.key});

  Future<void> _checkout(
    BuildContext context,
    WidgetRef ref,
    double cartTotal,
  ) async {
    // final cartItem = ref.watch(cartProvider)[0];
    final cart = ref.watch(cartProvider);
    // 为了性能所以可能中间转换过程用了map,导致ref.watch(cartProvider)[0]拿到的购物车数据和实际列表中顺序不一致
    final p = ref.watch(cartProvider)[0].product;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final cart = ref.watch(cartProvider);
          final qty = cart
              .where((c) => c.product.id == p.id)
              .fold(0, (_, item) => item.quantity);
          final cartCount = ref.watch(cartCountProvider);
          final cartTotal = ref.watch(cartTotalProvider);
          return AlertDialog(
            title: const Text('确认结算'),
            content: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () =>
                          ref.read(cartProvider.notifier).remove(p),
                    ),
                    Text('当前有${qty}件'),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () => ref.read(cartProvider.notifier).add(p),
                    ),
                  ],
                ),
                Text('共 $cartCount 件商品，合计 ¥${cartTotal.toStringAsFixed(2)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('确认'),
              ),
            ],
          );
        },
      ),
    );
    if (confirmed != true) return;
    ref
        .read(orderProvider.notifier)
        .checkout(ref.read(cartProvider), cartTotal);
    ref.read(cartProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredProductsProvider);
    final cart = ref.watch(cartProvider);
    final cartCount = ref.watch(cartCountProvider);
    final cartSubtotal = ref.watch(cartSubtotalProvider);
    final cartTax = ref.watch(cartTaxProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final orders = ref.watch(orderProvider);

    return TechDetailShell(
      title: 'Riverpod — 编译安全、自动 dispose',
      child: Column(
        children: [
          // 购物车状态栏
          Container(
            color: Colors.teal.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart),
                const SizedBox(width: 8),
                Text('$cartCount 件'),
                const Spacer(),
                Text('¥${cartTotal.toStringAsFixed(2)}'),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: cartCount == 0
                      ? null
                      : () => _checkout(context, ref, cartTotal),
                  child: const Text('结算'),
                ),
              ],
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
                  onChanged: (v) =>
                      ref.read(searchQueryProvider.notifier).state = v,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: kCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = kCategories[i];
                      return ChoiceChip(
                        label: Text(cat),
                        selected: ref.watch(categoryProvider) == cat,
                        onSelected: (v) {
                          if (v)
                            ref.read(categoryProvider.notifier).state = cat;
                        },
                      );
                    },
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
                final cart = ref.watch(cartProvider);
                final idx = cart.indexWhere((c) => c.product.id == p.id);
                final inCart = idx >= 0;
                final qty = inCart ? cart[idx].quantity : 0;
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
                                  ref.read(cartProvider.notifier).remove(p),
                            ),
                            Text('$qty'),
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              onPressed: () =>
                                  ref.read(cartProvider.notifier).add(p),
                            ),
                          ],
                        )
                      : FilledButton(
                          onPressed: () =>
                              ref.read(cartProvider.notifier).add(p),
                          child: const Text('加入'),
                        ),
                );
              },
            ),
          ),
          // 购物车明细
          if (cart.isNotEmpty)
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
                            '小计 ¥${cartSubtotal.toStringAsFixed(2)}  |  税 ¥${cartTax.toStringAsFixed(2)}  |  合计 ¥${cartTotal.toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: cart
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
          if (orders.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              color: Colors.blue.shade50,
              child: ListView(
                children: orders
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
            ),
        ],
      ),
    );
  }
}
