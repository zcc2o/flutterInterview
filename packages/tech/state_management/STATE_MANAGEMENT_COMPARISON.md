# 状态管理方案对比

本文对比本模块中演示的 5 种 Flutter 状态管理方案。

## 方案概览

| 方案 | 核心机制 | 依赖 |
|------|---------|------|
| **setState** | StatefulWidget + setState() | 无 |
| **ChangeNotifier** | ChangeNotifier + ListenableBuilder | 无 |
| **Provider** | ChangeNotifierProvider + Consumer/Selector | provider |
| **InheritedWidget** | 自定义 InheritedWidget + dependOnInheritedWidgetOfExactType | 无 |
| **Riverpod** | Provider/Notifier/StateProvider + ConsumerWidget | flutter_riverpod |

---

## 1. 重建粒度

| 方案 | 粒度 | 说明 |
|------|------|------|
| setState | **粗** — 全树重建 | 调用 setState 后整个 build 方法重新执行，子 widget 全部重建 |
| ChangeNotifier | **中等** — 按 ListenableBuilder 范围 | ListenableBuilder 只重建其 builder 回调中的子树，可嵌套控制范围 |
| Provider | **细** — Consumer/Selector 精确控制 | Consumer 只重建其 builder 子树；Selector 可指定 selector 函数，仅当返回值变化时才重建 |
| InheritedWidget | **粗** — 依赖祖先的整个子树 | 调用 dependOnInheritedWidgetOfExactType 的 widget 及其子树会重建 |
| Riverpod | **细** — 按 watch 范围 | ConsumerWidget 只重建 widget 中读取变化的 provider 的部分 |

**结论**: Provider 和 Riverpod 的重建粒度最细。

---

## 2. 模板代码量

| 方案 | 模板量 | 说明 |
|------|--------|------|
| setState | **少** | 只需 StatefulWidget + setState，业务逻辑和 UI 混在一起 |
| ChangeNotifier | **中** | 每个 Model 需 extends ChangeNotifier 并手动调用 notifyListeners() |
| Provider | **中** | 额外需要 MultiProvider + ChangeNotifierProvider 做依赖注入；UI 侧用 Consumer/Selector |
| InheritedWidget | **多** | 每个数据域需自定义 InheritedWidget 子类、updateShouldNotify、静态 of() 方法 |
| Riverpod | **少** | Provider 声明在顶层（全局），UI 侧只需 ConsumerWidget + ref.watch/read |

**结论**: setState 和 Riverpod 的模板代码最少，InheritedWidget 最多。

---

## 3. dispose 管理

| 方案 | dispose | 说明 |
|------|---------|------|
| setState | 手动 | 需手动 dispose TextEditingController、Timer 等资源（在 State.dispose 中） |
| ChangeNotifier | 手动 | 需手动调用 model.dispose()（在 State.dispose 中） |
| Provider | **自动** | ChangeNotifierProvider 在 widget 从树中移除时自动调用 model.dispose() |
| InheritedWidget | 手动 | InheritedWidget 本身不可变，数据由外层 StatefulWidget 持有，需手动管理 |
| Riverpod | **自动** | Provider 在不再被监听时自动 dispose（autoDispose 默认行为） |

**结论**: Provider 和 Riverpod 自动管理生命周期，减少内存泄漏风险。

---

## 4. 编译安全

| 方案 | 编译安全 | 说明 |
|------|---------|------|
| setState | ❌ 运行时 | 无编译期检查 |
| ChangeNotifier | ❌ 运行时 | listenable 类型在运行期绑定 |
| Provider | ❌ 运行时 | context.read<T>() 若 T 未提供则运行时报 ProviderNotFoundException |
| InheritedWidget | ❌ 运行时 | of() 方法使用 `!` 强制解包，若无祖先则 NPE |
| Riverpod | **✅ 编译时** | Provider 是全局声明，ref.watch 在编译期即可检查类型；不依赖 BuildContext |

**结论**: Riverpod 唯一提供编译期安全保障。

---

## 5. 异步支持

| 方案 | 异步 | 说明 |
|------|------|------|
| setState | 需手动处理 | setState 中调用异步方法需自行管理 loading/error 状态 |
| ChangeNotifier | 需手动处理 | 同上，需在 ChangeNotifier 中维护 loading/error 状态 |
| Provider | 需手动处理 | 同上，可通过 ChangeNotifier 封装 |
| InheritedWidget | 需手动处理 | 同上 |
| Riverpod | **内置** | AsyncNotifierProvider、FutureProvider、StreamProvider 原生支持 async 状态 |

**结论**: Riverpod 对异步场景支持最完善。

---

## 6. 学习曲线

| 方案 | 难度 | 说明 |
|------|------|------|
| setState | ⭐ | 最简单，Flutter 入门必学 |
| ChangeNotifier | ⭐⭐ | 理解观察者模式即可，Flutter 官方推荐的基础方案 |
| Provider | ⭐⭐ | 在 ChangeNotifier 基础上加了 DI 概念，Consumer/Selector 简单直观 |
| InheritedWidget | ⭐⭐⭐ | 需理解 Flutter 的 Element 树和依赖机制，updateShouldNotify 易写错 |
| Riverpod | ⭐⭐⭐ | 概念较多（Provider、Notifier、Family、autoDispose），但一致性好 |

**结论**: setState 最易上手，InheritedWidget 和 Riverpod 需要更多学习投入。

---

## 7. 性能

| 方案 | 性能 | 说明 |
|------|------|------|
| setState | ⚠️ 大量重建 | 状态变化导致全树 diff，列表项多时可能掉帧 |
| ChangeNotifier | ✅ 局部重建 | ListenableBuilder 限制重建范围 |
| Provider | ✅ 精确重建 | Selector 可实现最小化重建（仅变化的部分） |
| InheritedWidget | ✅ 依赖追踪 | 只有 dependOnInheritedWidget 的 widget 才重建 |
| Riverpod | ✅ 精确重建 | Provider 按粒度自动追踪依赖 |

**结论**: 除 setState 外，其余方案都能实现局部/精确重建。

---

## 8. 可测试性

| 方案 | 可测试性 | 说明 |
|------|---------|------|
| setState | 中 | 需测试 Widget，状态和 UI 耦合 |
| ChangeNotifier | ✅ 好 | Model 可独立单元测试（纯 Dart，无 Flutter 依赖） |
| Provider | ✅ 好 | 同上，Model 可单测；UI 测试可通过 Provider 注入 mock |
| InheritedWidget | 中 | 依赖 Widget 树层级，测试需构建完整上下文 |
| Riverpod | **最好** | Provider 可独立测试（ProviderContainer），支持 override 注入 mock |

**结论**: Riverpod 的可测试性最好，Provider 次之。

---

## 最终推荐

| 场景 | 推荐方案 |
|------|---------|
| 学习起步 / 简单页面 | setState |
| 中小型项目，快速开发 | Provider |
| 需要编译安全、复杂异步 | Riverpod |
| 仅需要跨组件共享少量数据 | InheritedWidget 或 Provider |
| 教学/理解 Flutter 机制 | InheritedWidget + ChangeNotifier |

> **总结趋势**: `setState` → `ChangeNotifier` → `Provider` → `Riverpod` 体现了从"手动全量刷新"到"自动精确更新 + 编译安全"的演进方向。
