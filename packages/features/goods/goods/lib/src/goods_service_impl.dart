import 'package:trade_interfaces/trade_interfaces.dart';

/// 商品服务实现
///
/// 实现了 trade_interfaces 中定义的 IGoodsService 接口。
/// 位于 lib/src/，外部模块不可直接导入。
class GoodsServiceImpl implements IGoodsService {
  static const _mockGoods = <String, GoodsItem>{
    'g001': GoodsItem(
      id: 'g001',
      name: 'iPhone 16 Pro Max',
      price: 9999.00,
      imageUrl: 'https://example.com/iphone16.png',
      stock: 128,
    ),
    'g002': GoodsItem(
      id: 'g002',
      name: 'AirPods Pro 第三代',
      price: 1899.00,
      imageUrl: 'https://example.com/airpods.png',
      stock: 350,
    ),
    'g003': GoodsItem(
      id: 'g003',
      name: 'MacBook Pro 16英寸 M4',
      price: 19999.00,
      imageUrl: 'https://example.com/macbook.png',
      stock: 45,
    ),
  };

  @override
  Future<GoodsItem> getGoodsById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final goods = _mockGoods[id];
    if (goods == null) throw Exception('商品不存在: $id');
    return goods;
  }

  @override
  Future<List<GoodsItem>> getGoodsByIds(List<String> ids) async {
    final results = await Future.wait(ids.map(getGoodsById));
    return results;
  }
}
