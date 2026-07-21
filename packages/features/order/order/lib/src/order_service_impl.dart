import 'package:trade_interfaces/trade_interfaces.dart';

/// 订单服务实现
///
/// 通过构造函数注入 IGoodsService 接口。
/// 注意：此文件只 import trade_interfaces，不 import goods 包！
/// goods 模块的内部实现对此文件完全透明。
class OrderServiceImpl implements IOrderService {
  final IGoodsService _goodsService;

  OrderServiceImpl(this._goodsService);

  static final _dummyDate = DateTime(2026, 7, 15);
  static final _mockOrders = <String, Order>{
    'o001': Order(
      id: 'o001',
      customerName: '张三',
      items: const [
        OrderItem(goodsId: 'g001', quantity: 1, unitPrice: 9999.00),
        OrderItem(goodsId: 'g002', quantity: 2, unitPrice: 1899.00),
      ],
      createdAt: _dummyDate,
    ),
    'o002': Order(
      id: 'o002',
      customerName: '李四',
      items: const [
        OrderItem(goodsId: 'g003', quantity: 1, unitPrice: 19999.00),
      ],
      createdAt: _dummyDate,
    ),
  };

  @override
  Future<OrderDetail> getOrderDetail(String orderId) async {
    final order = _mockOrders[orderId];
    if (order == null) throw Exception('订单不存在: $orderId');

    // 通过接口获取商品信息 —— 完全不依赖 goods 模块！
    final goodsItems = await _goodsService.getGoodsByIds(order.goodsIds);

    return OrderDetail(order: order, goodsItems: goodsItems);
  }
}
