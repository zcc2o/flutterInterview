import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/goods_detail_screen.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.goodsDetail: GoRoute(
    path: InterviewRoutes.goodsDetail.path,
    builder: (context, state) {
      // 从路由参数获取商品 ID，默认为示例 ID
      final goodsId = state.uri.queryParameters['id'] ?? 'g001';
      return GoodsDetailScreen(goodsId: goodsId);
    },
  ),
};
