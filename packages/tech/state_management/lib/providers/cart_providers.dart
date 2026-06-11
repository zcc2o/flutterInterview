import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

// ==============================================================================
// CartNotifier — 购物车业务逻辑
// ==============================================================================
// 使用 NotifierProvider（AlwaysAlive），购物车数据需要跨页面持久化。
// 用户在页面 A 添加商品后切换到页面 B，购物车不应该被清空。

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

  void remove(Product product) {
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

// ==============================================================================
// Cart — AlwaysAlive，跨页面持久化
// ==============================================================================
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

// ==============================================================================
// 购物车派生计算属性 — autoDispose（纯计算，重建成本低，无人监听时自动释放）
// ==============================================================================

/// 购物车商品总数量
final cartCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(cartProvider).fold(0, (s, c) => s + c.quantity);
});

/// 购物车小计（不含税）
final cartSubtotalProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(cartProvider).fold(0.0, (s, c) => s + c.subtotal);
});

/// 税费
final cartTaxProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(cartSubtotalProvider) * kTaxRate;
});

/// 总费用（含税）
final cartTotalProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(cartSubtotalProvider) + ref.watch(cartTaxProvider);
});
