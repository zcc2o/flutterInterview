import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/immutable_product.dart';

// ==============================================================================
// ImprovedOrderNotifier — 订单（配合不可变购物车使用）
// ==============================================================================

class ImprovedOrderNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() => [];

  void checkout(List<CartItemImmutable> items, double total) {
    state = [
      Order(
        items: items
            .map((i) => CartItem(
                  product: i.product,
                  quantity: i.quantity,
                ))
            .toList(),
        total: total,
        createdAt: DateTime.now(),
      ),
      ...state,
    ];
  }
}

// ==============================================================================
// Improved Order — AlwaysAlive
// ==============================================================================
final improvedOrderProvider =
    NotifierProvider<ImprovedOrderNotifier, List<Order>>(
  ImprovedOrderNotifier.new,
);
