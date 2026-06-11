import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/immutable_product.dart';

// ==============================================================================
// ImprovedCartNotifier — 使用不可变数据模型的购物车
// ==============================================================================
// 对比 CartNotifier：CartItem → CartItemImmutable，copyWith 替代手动构造。

class ImprovedCartNotifier extends Notifier<List<CartItemImmutable>> {
  @override
  List<CartItemImmutable> build() => [];

  void add(Product product) {
    final idx = state.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      // ✅ copyWith：在原实例基础上只改 quantity，返回新实例
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == idx)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, CartItemImmutable(product: product)];
    }
  }

  void remove(Product product) {
    final idx = state.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      final item = state[idx];
      if (item.quantity > 1) {
        // ✅ copyWith：数量减 1，返回新 CartItemImmutable
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == idx)
              state[i].copyWith(quantity: state[i].quantity - 1)
            else
              state[i],
        ];
      } else {
        state = state.where((c) => c.product.id != product.id).toList();
      }
    }
  }

  void clear() => state = [];
}

// ==============================================================================
// Improved Cart — AlwaysAlive
// ==============================================================================
final improvedCartProvider =
    NotifierProvider<ImprovedCartNotifier, List<CartItemImmutable>>(
  ImprovedCartNotifier.new,
);

// ==============================================================================
// 派生计算属性 — autoDispose
// ==============================================================================

final improvedCartCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(improvedCartProvider).fold(0, (s, c) => s + c.quantity);
});

final improvedCartSubtotalProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(improvedCartProvider).fold(0.0, (s, c) => s + c.subtotal);
});

final improvedCartTaxProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(improvedCartSubtotalProvider) * kTaxRate;
});

final improvedCartTotalProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(improvedCartSubtotalProvider) + ref.watch(improvedCartTaxProvider);
});
