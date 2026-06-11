import 'package:flutter/foundation.dart';
import 'product.dart';

// ==============================================================================
// 面试重点：数据模型不可变性（Immutability）
// ==============================================================================
//
// 面试官追问的三样东西其实是一个体系：
//
//   freeze / Freezed  → 一个 Dart 代码生成包，能自动生成 copyWith、==、toString、JSON 序列化
//   copyWith           → 不可变对象上"创建修改后副本"的方法
//   注解 (Annotation)  → @freezed、@immutable 这些标记，告诉分析器或代码生成器做什么
//
// 三者关系：
//   @freezed 注解 → build_runner 运行 Freezed → 自动生成 copyWith + == + toString
//   @immutable 注解 → Dart 分析器检查所有字段是否 final
//   copyWith 方法   → 返回一个"只改了某字段"的新实例，原实例不变
//
// ==============================================================================

// ------------------------------------------------------------------------------
// 版本 1 ❌ 可变数据模型 —— 面试中被指出的问题
// ------------------------------------------------------------------------------
// 这是当前项目中 product.dart 里的 CartItem 写法：
//   class CartItem {
//     final Product product;
//     int quantity;           // ← 注意：不是 final！可以直接修改！
//     ...
//   }
//
// 问题在哪？
//   1. 可以直接写 cartItem.quantity = 5，原地修改对象
//   2. Riverpod 通过"引用比较"检测状态变化 —— 同一个对象引用 = Riverpod 认为状态没变
//   3. 原地修改后 Riverpod 不会通知监听者 → UI 不重建 → Bug！
//   4. 不符合函数式编程 / 不可变数据的推荐实践
//
// 面试官看到这种写法，就会追问"有没有做只读不可改？"

class CartItemMutable {
  final Product product;
  int quantity; // ← 可变字段！面试官指出的问题就在这

  CartItemMutable({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  @override
  String toString() => 'CartItemMutable(product: ${product.name}, quantity: $quantity)';
}

// ------------------------------------------------------------------------------
// 版本 2 ✅ 不可变数据模型 + 手动 copyWith —— 本项目推荐做法
// ------------------------------------------------------------------------------
// 设计思路：
//   1. 所有字段都是 final → 构造后不可修改 → "只读不可改"
//   2. 用 @immutable 注解 → Dart 分析器会帮你检查，如果加了非 final 字段就报警
//   3. 提供 copyWith 方法 → 要"修改"时，创建新实例返回，原实例不动
//   4. const 构造函数 → 编译时常量优化
//
// 为什么这样设计对 Riverpod 很重要？
//   Riverpod 的 state setter 大致等价于：
//     if (newState != _state) { _state = newState; notifyListeners(); }
//   "!=" 在 Dart 里是比较对象引用（identity check）
//   copyWith 每次都返回新实例 → 新引用 → Riverpod 检测到变化 → 触发重建 ✅
//   原地修改不产生新引用 → Riverpod 检测不到 → UI 不更新 ❌

@immutable
class CartItemImmutable {
  final Product product;
  final int quantity; // ← 现在是 final！不能直接改，必须用 copyWith

  const CartItemImmutable({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  /// 创建当前实例的副本，只替换传入的字段
  ///
  /// 用法：
  ///   // 数量 +1
  ///   final newItem = item.copyWith(quantity: item.quantity + 1);
  ///   // 只换 product（这种情况少，但方法支持）
  ///   final newItem = item.copyWith(product: anotherProduct);
  ///
  /// 每次调用都返回一个全新的 CartItemImmutable 实例，
  /// 原实例完全不变 —— 这就是"不可变性"的核心。
  CartItemImmutable copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItemImmutable(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemImmutable &&
        other.product.id == product.id &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => Object.hash(product.id, quantity);

  @override
  String toString() => 'CartItemImmutable(product: ${product.name}, quantity: $quantity)';
}

// ------------------------------------------------------------------------------
// 版本 3 🤖 Freezed 注解驱动 —— 面试中 "freeze" 指的就是这个
// ------------------------------------------------------------------------------
//
// 下面的代码是注释掉的，因为需要额外的依赖和构建步骤才能运行。
// 但它展示的就是面试官说的"freeze"的完整写法。
//
// 要让它跑起来，需要三步：
//   1. pubspec.yaml 加依赖：
//      dependencies:
//        freezed_annotation: ^2.4.0
//      dev_dependencies:
//        build_runner: ^2.4.0
//        freezed: ^2.5.0
//
//   2. 写下面的代码（@freezed 注解 + factory 构造函数）
//
//   3. 运行：dart run build_runner build
//
//   然后 Freezed 会自动生成：
//     - CartItemFreezed 类（所有字段 final）
//     - copyWith 方法
//     - == / hashCode
//     - toString
//     - JSON 序列化（搭配 json_serializable）
//
// 版本 2 里我们手动写的 30 行代码（copyWith + == + hashCode + toString），
// Freezed 一行注解全部搞定 —— 这就是它的价值。
//
// ```dart
// import 'package:freezed_annotation/freezed_annotation.dart';
//
// part 'immutable_product.freezed.dart';       // Freezed 会生成这个文件
// part 'immutable_product.g.dart';            // 如果用 JSON，也会生成这个
//
// @freezed                                     // ← 这就是面试官说的"注解"
// class CartItemFreezed with _$CartItemFreezed {
//   const factory CartItemFreezed({            // ← factory 构造函数
//     required Product product,
//     @Default(1) int quantity,                // @Default 也是注解，设默认值
//   }) = _CartItemFreezed;
// }
// ```
//
// 上面 10 行代码，Freezed 会生成一个几百行的 .freezed.dart 文件，
// 包含完整的 copyWith、==、hashCode、toString 实现。
// 这就是"注解驱动代码生成"的含义：
//   你写注解（@freezed）  →  描述数据结构（factory）  →  工具生成实现代码
//
// ==============================================================================
// 总结面试要点
// ==============================================================================
//
// 面试官："数据模型有什么设计思路？有没有做只读不可改？"
//
// 标准回答思路：
//   "我的数据模型采用不可变设计（Immutable）。
//    所有字段都是 final，通过 copyWith 方法创建修改后的副本。
//    在简单项目中手动实现 copyWith + == + hashCode，
//    复杂项目会使用 Freezed 代码生成，通过 @freezed 注解自动生成这些方法。
//    这样设计的原因是：Riverpod / BLoC 等状态管理框架通过引用比较检测状态变化，
//    只有返回新实例才能触发 UI 重建，原地修改是检测不到的。"
//
// 三个关键词的对应：
//   只读不可改  → 所有字段 final，用 @immutable 注解约束
//   freeze     → Freezed 包，通过 @freezed 注解自动生成不可变代码
//   copyWith   → 不可变对象上创建修改副本的方法
//   注解        → @freezed / @immutable / @Default 等 Dart 元数据标记
// ==============================================================================
