import 'goods_model.dart';

/// 商品服务接口 — 只定义契约
///
/// goods 模块实现此接口，order 模块调用此接口。
/// 二者都只依赖 trade_interfaces，互不知道对方的存在。
abstract interface class IGoodsService {
  Future<GoodsItem> getGoodsById(String id);
  Future<List<GoodsItem>> getGoodsByIds(List<String> ids);
}
