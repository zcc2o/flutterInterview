/// 交易域接口契约
///
/// goods 和 order 模块都依赖此包，但互不依赖对方。
/// 此包只放接口 + 纯数据类，零业务逻辑。
///
/// 【类比 Bifrost】此包就相当于 Bifrost 的 Mediator 层，
/// 集中存放 Protocol 定义，让业务模块之间零耦合。
library trade_interfaces;

export 'goods_model.dart';
export 'goods_service.dart';
export 'order_model.dart';
export 'order_service.dart';
