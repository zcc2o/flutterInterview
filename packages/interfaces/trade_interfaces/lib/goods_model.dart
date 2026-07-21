/// 商品数据模型 — 纯数据类，属于交易域的共享契约
class GoodsItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final int stock;

  const GoodsItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.stock,
  });

  String get priceText => '¥${price.toStringAsFixed(2)}';
}
