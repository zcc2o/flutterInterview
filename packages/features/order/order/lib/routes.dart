import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'package:trade_interfaces/trade_interfaces.dart';
import 'screens/order_detail_screen.dart';

/// 创建订单模块路由
///
/// goodsService 由壳工程注入 —— order 模块不知道具体实现是什么
Map<InterviewRoutes, GoRoute> createOrderRoutes({
  required IGoodsService goodsService,
}) {
  return {
    InterviewRoutes.orderDetail: GoRoute(
      path: InterviewRoutes.orderDetail.path,
      builder: (context, state) {
        final orderId = state.uri.queryParameters['id'] ?? 'o001';
        return OrderDetailScreen(
          orderId: orderId,
          goodsService: goodsService,
        );
      },
    ),
  };
}
