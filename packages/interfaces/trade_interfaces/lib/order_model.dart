import 'goods_model.dart';

/// 订单条目
class OrderItem {
  final String goodsId;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.goodsId,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;
}

/// 订单
class Order {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerName,
    required this.items,
    required this.createdAt,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);
  String get totalText => '¥${totalAmount.toStringAsFixed(2)}';
  List<String> get goodsIds => items.map((item) => item.goodsId).toList();
}

/// 订单详情 — 组合订单 + 商品信息
class OrderDetail {
  final Order order;
  final List<GoodsItem> goodsItems;

  const OrderDetail({required this.order, required this.goodsItems});
}
