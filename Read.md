# Flutter 业务模块解耦方案：基于接口契约 + 依赖注入

## 一、问题背景

在 Flutter 中大型应用中，业务模块之间存在天然的耦合需求。举一个典型场景：

> 订单模块需要展示订单中的商品信息（商品名、价格、图片），但商品数据归商品模块管理。

最直观的写法是订单模块直接依赖商品模块：

```dart
// order/pubspec.yaml
dependencies:
  goods:
    path: ../goods

// order/lib/order_service.dart
import 'package:goods/goods.dart';  // 直接依赖商品模块

class OrderService {
  final GoodsRepository _goodsRepo;  // 直接引用商品模块的实现类
}
```

**这带来的问题：**

| 问题 | 影响 |
|------|------|
| 编译期强耦合 | 订单模块编译依赖商品模块，改商品必重编订单 |
| 重构困难 | 商品模块换数据库/换网络层，订单模块跟着改 |
| 测试困难 | 订单模块单测必须带着真实的商品模块 |
| 团队协作冲突 | 两个团队同时改对方依赖的模块，PR 频繁冲突 |
| Git 冲突 | pubspec.yaml 和 import 耦合导致合并冲突 |

**目标：订单模块和商品模块在编译层面完全解耦，互不感知对方的存在。**

---

## 二、核心思路：依赖倒置 + 中介层

借用了两个经典设计原则：

### 2.1 依赖倒置原则（Dependency Inversion Principle）

```
高层模块不应依赖低层模块，二者都应依赖抽象。
抽象不应依赖细节，细节应依赖抽象。
```

翻译成 Flutter 代码：

```dart
// ❌ 订单依赖商品的具体实现
class OrderService {
  final GoodsServiceImpl _goodsService;  // 依赖具体类
}

// ✅ 订单依赖抽象接口
class OrderService {
  final IGoodsService _goodsService;     // 依赖接口
}
```

### 2.2 中介者模式（类比有赞 Bifrost）

有赞 iOS 团队在 2016 年推出了 Bifrost 组件化框架，核心设计：

```
┌─────────────────────────────────────────┐
│  Mediator 层（只存放 Protocol 定义）      │
├─────────────────────────────────────────┤
│  Module A  ──→  Protocol  ←──  Module B │
│  (实现接口)    (接口契约)     (调用接口)   │
└─────────────────────────────────────────┘
```

**Module A 和 Module B 互不依赖，都只依赖 Mediator 中的 Protocol。**

---

## 三、方案演进

在落地过程中，方案经历了三次迭代：

### 3.1 方案一：大 Core 层（❌ 否决）

把所有共享类型、接口全部下沉到一个 `core` 包：

```
core/
├── models/
│   ├── goods_model.dart
│   ├── order_model.dart
│   ├── user_model.dart      ← 越塞越多
│   ├── payment_model.dart
│   └── ...100+ 文件
```

**否决原因：** Core 层会随项目无限膨胀，成为所有团队修改的热点，失去模块化的意义。

### 3.2 方案二：每模块拆 API 子包（❌ 否决）

```
goods/
├── goods_api/     ← 包数翻倍！
│   └── lib/       ← 接口 + 数据类
└── goods/         ← 实现
    └── lib/
```

**否决原因：** N 个业务模块变成 2N 个包，目录结构臃肿，维护成本高。虽然解决了耦合，但工程复杂度翻倍。

### 3.3 方案三：按业务域拆分接口包（✅ 最终采用）

**每个业务域一个轻量接口包，只放该域模块间共享的契约：**

```
packages/
├── interfaces/
│   └── trade_interfaces/          ← 交易域共享契约（约等于 Bifrost 的 Mediator）
│       └── lib/
│           ├── goods_model.dart   ← GoodsItem（纯数据类）
│           ├── goods_service.dart ← abstract IGoodsService
│           ├── order_model.dart   ← Order、OrderItem、OrderDetail
│           └── order_service.dart ← abstract IOrderService
├── features/
│   ├── goods/                     ← 只依赖 trade_interfaces
│   │   └── lib/src/
│   │       └── goods_service_impl.dart  (implements IGoodsService)
│   └── order/                     ← 只依赖 trade_interfaces，不依赖 goods！
│       └── lib/src/
│           └── order_service_impl.dart  (注入 IGoodsService)
└── apps/App/                      ← 依赖 trade_interfaces + goods + order
    └── config/routes.dart         (DI 组装点)
```

**依赖关系图：**

```
                   trade_interfaces (纯契约，零业务逻辑)
                      ↗         ↖
                    ↗             ↖
                  goods           order        ← 互不依赖！互不知道对方存在！
                    ↗             ↖
                  ↗                 ↖
                └────── app ─────────┘         ← 唯一知道所有模块的地方
```

**关键验证：**

```
order/pubspec.yaml 的依赖：
  trade_interfaces  ← 只有这个
  interview_core
  interview_widgets
  没有 goods！       ← 编译期硬约束
```

---

## 四、完整代码实现

### 4.1 trade_interfaces — 接口契约层

**`pubspec.yaml`** — 零外部依赖，只依赖 Flutter SDK：
```yaml
name: trade_interfaces
description: 交易域接口契约 — goods 和 order 共享的接口 + 纯数据类

environment:
  sdk: ">=3.9.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
```

**`goods_model.dart`** — 纯数据类，无业务逻辑：
```dart
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
```

**`goods_service.dart`** — 接口契约，使用 Dart 3 的 `abstract interface class`：
```dart
import 'goods_model.dart';

/// goods 模块实现此接口，order 模块调用此接口。
/// 二者都只依赖 trade_interfaces，互不知道对方的存在。
abstract interface class IGoodsService {
  Future<GoodsItem> getGoodsById(String id);
  Future<List<GoodsItem>> getGoodsByIds(List<String> ids);
}
```

**`order_model.dart`** — 订单模型，其中 `OrderDetail` 组合了 `GoodsItem`：
```dart
import 'goods_model.dart';

class OrderItem {
  final String goodsId;
  final int quantity;
  final double unitPrice;
  const OrderItem({required this.goodsId, required this.quantity, required this.unitPrice});
  double get subtotal => quantity * unitPrice;
}

class Order {
  final String id;
  final String customerName;
  final List<OrderItem> items;
  final DateTime createdAt;
  const Order({required this.id, required this.customerName, required this.items, required this.createdAt});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);
  String get totalText => '¥${totalAmount.toStringAsFixed(2)}';
  List<String> get goodsIds => items.map((item) => item.goodsId).toList();
}

/// 订单详情 — 组合了订单数据和商品信息，这是"跨模块数据组合"的载体
class OrderDetail {
  final Order order;
  final List<GoodsItem> goodsItems;
  const OrderDetail({required this.order, required this.goodsItems});
}
```

**`order_service.dart`** — 订单服务接口：
```dart
import 'order_model.dart';

abstract interface class IOrderService {
  Future<OrderDetail> getOrderDetail(String orderId);
}
```

**barrel 导出文件 `trade_interfaces.dart`**：
```dart
library trade_interfaces;

export 'goods_model.dart';
export 'goods_service.dart';
export 'order_model.dart';
export 'order_service.dart';
```

### 4.2 goods 模块 — 接口的实现方

**`pubspec.yaml`** — 只依赖接口包：
```yaml
name: goods
dependencies:
  trade_interfaces:
    path: ../../../interfaces/trade_interfaces
  # 没有 order 依赖！
```

**`lib/src/goods_service_impl.dart`** — 实现（位于 `src/`，Dart 约定私有）：
```dart
import 'package:trade_interfaces/trade_interfaces.dart';

class GoodsServiceImpl implements IGoodsService {
  static const _mockGoods = <String, GoodsItem>{
    'g001': GoodsItem(id: 'g001', name: 'iPhone 16 Pro Max', price: 9999.00, imageUrl: '...', stock: 128),
    'g002': GoodsItem(id: 'g002', name: 'AirPods Pro 第三代', price: 1899.00, imageUrl: '...', stock: 350),
    'g003': GoodsItem(id: 'g003', name: 'MacBook Pro 16英寸 M4', price: 19999.00, imageUrl: '...', stock: 45),
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
    return Future.wait(ids.map(getGoodsById));
  }
}
```

### 4.3 order 模块 — 接口的调用方

**`pubspec.yaml`** — 只依赖接口包，没有 `goods`：
```yaml
name: order
dependencies:
  trade_interfaces:
    path: ../../../interfaces/trade_interfaces
  # 注意：没有 goods 依赖！
```

**`lib/src/order_service_impl.dart`** — 构造函数注入 `IGoodsService` 接口：
```dart
import 'package:trade_interfaces/trade_interfaces.dart';

class OrderServiceImpl implements IOrderService {
  final IGoodsService _goodsService;  // ← 接口类型，不关心实现是谁

  OrderServiceImpl(this._goodsService);  // ← 构造函数注入

  @override
  Future<OrderDetail> getOrderDetail(String orderId) async {
    // 1. 获取订单数据（自己的逻辑）
    final order = _mockOrders[orderId];
    if (order == null) throw Exception('订单不存在: $orderId');

    // 2. 通过接口获取商品信息 — 不知道 goods 模块的存在！
    final goodsItems = await _goodsService.getGoodsByIds(order.goodsIds);

    return OrderDetail(order: order, goodsItems: goodsItems);
  }
}
```

**`lib/routes.dart`** — 由壳工程通过函数参数注入依赖：
```dart
import 'package:trade_interfaces/trade_interfaces.dart';

Map<InterviewRoutes, GoRoute> createOrderRoutes({
  required IGoodsService goodsService,  // ← 由壳工程注入
}) {
  return {
    InterviewRoutes.orderDetail: GoRoute(
      path: InterviewRoutes.orderDetail.path,
      builder: (context, state) {
        final orderId = state.uri.queryParameters['id'] ?? 'o001';
        return OrderDetailScreen(orderId: orderId, goodsService: goodsService);
      },
    ),
  };
}
```

### 4.4 App 壳工程 — DI 组装点

**`pubspec.yaml`** — 依赖所有模块（壳工程是唯一知道全貌的地方）：
```yaml
name: interview_app
dependencies:
  trade_interfaces:
    path: ../../interfaces/trade_interfaces
  goods:
    path: ../../features/goods/goods
  order:
    path: ../../features/order/order
```

**`config/routes.dart`** — 唯一的 DI 组装入口：
```dart
import 'package:goods/src/goods_service_impl.dart';  // 壳工程例外导入 src/
import 'package:order/routes.dart' as order;

// ============================================================
// 【壳工程 — DI 组装点】
// 这是整个应用唯一需要同时知道 goods 和 order 两个模块的地方。
// ============================================================

/// 创建 GoodsServiceImpl 实例，作为 IGoodsService 注入给订单模块
final _goodsService = GoodsServiceImpl();

/// 创建订单路由时注入 goodsService
final _orderRoutes = order.createOrderRoutes(goodsService: _goodsService);

final router = GoRouter(
  initialLocation: InterviewRoutes.home.path,
  routes: [
    // ... 所有模块路由 ...
    ..._orderRoutes.values,
  ],
);
```

**壳工程导入 `lib/src/` 目录是合法例外** — Dart 的 `src/` 约定是"不建议其他包导入"，但壳工程作为 DI 组装点是唯一可以打破这个约定的地方。

---

## 五、方案优点

### 5.1 编译期硬约束

| 约束 | 如何保证 |
|------|---------|
| order 不依赖 goods | `order/pubspec.yaml` 中没有 `goods:` |
| goods 不依赖 order | `goods/pubspec.yaml` 中没有 `order:` |
| 只能访问接口 | order 只 import `trade_interfaces`，无法 import `goods/src/`（analyzer 警告） |
| 接口归属清晰 | 修改 `IGoodsService` 只在 `trade_interfaces` 中 |

### 5.2 可测试性

```dart
// 测试订单模块时，注入 Mock 实现，完全不需要 goods 模块
class MockGoodsService implements IGoodsService {
  @override
  Future<GoodsItem> getGoodsById(String id) async {
    return GoodsItem(id: id, name: '测试商品', price: 0, imageUrl: '', stock: 0);
  }
  // ...
}

void main() {
  test('订单总价计算正确', () async {
    final service = OrderServiceImpl(MockGoodsService());
    final detail = await service.getOrderDetail('o001');
    expect(detail.order.totalAmount, 9999.00 + 1899.00 * 2);
  });
}
```

### 5.3 独立编译

- 修改 `GoodsServiceImpl` 内部逻辑 → order 模块**不需要重新编译**
- 修改 `trade_interfaces` 中的接口 → 所有模块**都需要重新编译**（这是合理的，契约变了）
- goods 模块替换存储方案（SharedPreferences → Hive → sqflite）→ order 模块**零影响**

### 5.4 按域隔离，避免大 Core 膨胀

```
interfaces/
├── trade_interfaces/      ← 只放 goods + order 的共享类型
├── user_interfaces/       ← 只放 user + social 的共享类型（未来扩展）
└── payment_interfaces/    ← 只放 payment + order 的共享类型（未来扩展）
```

每个接口包范围小、责任单一，不会出现"一个大 Core 装一切"的问题。

---

## 六、与有赞 Bifrost 的对应

| Bifrost（iOS） | 本方案（Flutter） |
|---|---|
| Mediator 层集中存放 Protocol 头文件 | `trade_interfaces` 集中存放 `abstract interface class` |
| `BFModule(GoodsProtocol)` 宏获取实现 | `getIt<IGoodsService>()` 或构造函数注入 |
| 模块在 `+load` 中注册 | 壳工程 `routes.dart` 中手动组装 |
| 按 priority 初始化模块 | 壳工程控制组装顺序 |
| 模块之间零编译依赖 | pubspec.yaml 中无对方依赖 |
| URL 路由解耦页面跳转 | GoRouter + 路由枚举（`InterviewRoutes`） |
| NSNotification 广播事件 | EventBus / Stream（扩展） |

---

## 七、Mock 数据调用流程（实战演示）

以本项目为例，用户点击首页"订单模块"卡片后：

```
1. HomeScreen 触发 Navigator.pushNamed('/order/detail?id=o001')
   ↓
2. GoRouter 匹配 InterviewRoutes.orderDetail
   ↓
3. 壳工程 createOrderRoutes 中的 builder 被调用
   → 传入 _goodsService（GoodsServiceImpl 实例）
   ↓
4. OrderDetailScreen 收到 goodsService
   → 创建 OrderServiceImpl(goodsService)
   ↓
5. OrderServiceImpl.getOrderDetail('o001')
   → 查本地订单数据 → 得 [g001, g002]
   → 调 _goodsService.getGoodsByIds(['g001','g002'])
   → GoodsServiceImpl 返回 [iPhone, AirPods]
   → 组合成 OrderDetail 返回
   ↓
6. UI 渲染：订单号 + 客户名 + 商品卡片（名称、单价、数量） + 合计金额
```

整个过程中，`order` 模块的代码里**没有出现过一个 `import 'package:goods/...'`**。

---

## 八、适用场景与限制

### 适用

- 中大型 Flutter 项目（5+ 业务模块）
- 多团队协作，模块归属清晰
- 需要独立测试、独立编译
- 长期维护的项目（模块可能独立重构）

### 不适用

- 小型项目（< 3 模块）— 过度设计
- 单人开发 — 收益不明显
- 模块间有大量跨模块 UI 组合 — 考虑 Mosaic 等微前端方案

### 额外代价

| 代价 | 程度 |
|---|---|
| 多了一个 interfaces 包 | 中 — 每个业务域多一个包 |
| 需要建立"接口先行"的开发规范 | 中 — 团队需要达成共识 |
| 接口变更需要协调多个模块 | 低 — 接口本就应稳定 |

---

## 九、总结

这套方案的核心思想可以浓缩为三条规则：

1. **业务模块之间禁止直接 pubspec 依赖** — 编译期硬约束
2. **共享类型下沉到业务域专属的 interfaces 包** — 不搞大 Core，按域隔离
3. **壳工程是唯一的 DI 组装点** — 只有它有权限知道所有模块

本质上就是**用"接口契约 + 依赖注入"替代"模块间直接依赖"**，与有赞 Bifrost 的"Protocol + Mediator"是同一种架构思想在 Flutter/Dart 生态中的落地。
