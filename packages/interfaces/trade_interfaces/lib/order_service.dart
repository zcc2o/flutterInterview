import 'order_model.dart';

/// 订单服务接口
abstract interface class IOrderService {
  Future<OrderDetail> getOrderDetail(String orderId);
}
