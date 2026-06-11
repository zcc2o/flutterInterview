import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

// ==============================================================================
// OrderNotifier — 订单业务逻辑
// ==============================================================================
// 使用 NotifierProvider（AlwaysAlive），订单历史需要跨页面持久化。

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

// ==============================================================================
// Order — AlwaysAlive，跨页面持久化
// ==============================================================================
final orderProvider = NotifierProvider<OrderNotifier, List<Order>>(
  OrderNotifier.new,
);
