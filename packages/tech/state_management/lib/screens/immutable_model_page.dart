import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_widgets/interview_widgets.dart';
import '../models/product.dart';
import '../models/immutable_product.dart';

// ==============================================================================
// 交互式 Demo 专用的 Riverpod Provider
// ==============================================================================

/// 演示用：持有一个不可变的购物车项
final demoImmutableProvider =
    NotifierProvider<DemoNotifier, CartItemImmutable>(DemoNotifier.new);

class DemoNotifier extends Notifier<CartItemImmutable> {
  @override
  // ignore: prefer_const_constructors
  CartItemImmutable build() =>
      CartItemImmutable(product: kProducts[0], quantity: 1);

  void increase() =>
      state = state.copyWith(quantity: state.quantity + 1);

  void decrease() {
    if (state.quantity > 1) {
      state = state.copyWith(quantity: state.quantity - 1);
    }
  }

  void reset() =>
      // ignore: prefer_const_constructors
      state = CartItemImmutable(product: kProducts[0], quantity: 1);
}

// ==============================================================================
// 页面主体
// ==============================================================================

class ImmutableModelPage extends ConsumerWidget {
  const ImmutableModelPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TechDetailShell(
      title: '数据模型不可变性 — freeze / copyWith / 注解',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInterviewContext(context),
            const SizedBox(height: 16),
            _buildCodeComparison(context),
            const SizedBox(height: 16),
            _buildInteractiveDemo(ref),
            const SizedBox(height: 16),
            _buildWhyImmutability(context),
            const SizedBox(height: 16),
            _buildAnnotationExplainer(context),
            const SizedBox(height: 16),
            _buildWhyNoFreezedWorks(context),
            const SizedBox(height: 16),
            _buildInterviewAnswer(context),
          ],
        ),
      ),
    );
  }

  // ---- Section 1: 面试场景还原 -----------------------------------------------
  Widget _buildInterviewContext(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.orange.shade800),
                const SizedBox(width: 8),
                Text(
                  '面试场景还原',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text.rich(
              TextSpan(
                style: TextStyle(height: 1.6),
                children: [
                  TextSpan(
                    text:
                        '面试官先问：“Riverpod 用的 2 还是 3？”\n'
                        '你答了 2 之后，面试官追问：\n\n',
                  ),
                  TextSpan(
                    text:
                        '“数据模型有什么设计思路？'
                        '有没有做只读不可改（freeze、copyWith、注解）？”',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 13, height: 1.5),
                  children: [
                    TextSpan(
                      text: '\u{1F511} 面试官在考察什么？\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          '这题考察的是你对「数据层设计规范」的理解，不是问你怎么用 Riverpod。\n\n',
                    ),
                    TextSpan(
                      text: '• freeze ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    TextSpan(
                      text:
                          '→ Freezed 代码生成包，通过注解自动生成不可变代码\n',
                    ),
                    TextSpan(
                      text: '• copyWith ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    TextSpan(
                      text:
                          '→ 不可变对象上创建修改后副本的方法\n',
                    ),
                    TextSpan(
                      text: '• 注解 ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    TextSpan(
                      text:
                          '→ @freezed、@immutable 等 Dart 元数据标记',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Section 2: 三种方式代码对比 -------------------------------------------
  Widget _buildCodeComparison(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '代码对比：三种数据模型写法',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            // 版本 1：可变（反面）
            _buildExpansionTile(
              icon: '❌',
              iconColor: Colors.red,
              title: '版本 1：可变模型（当前代码的问题）',
              subtitle: 'quantity 非 final，可以原地修改',
              backgroundColor: Colors.red.shade50,
              textColor: Colors.red.shade900,
              code: 'class CartItem {\n'
                  '  final Product product;\n'
                  '  int quantity;   // ← ⚠️ 不是 final！\n'
                  '                  //   可以 cartItem.quantity = 5\n'
                  '                  //   Riverpod 检测不到这个变化！\n'
                  '\n'
                  '  CartItem({required this.product, this.quantity = 1});\n'
                  '  double get subtotal => product.price * quantity;\n'
                  '}',
            ),
            const SizedBox(height: 8),
            // 版本 2：不可变 + 手动 copyWith（正确）
            _buildExpansionTile(
              icon: '✅',
              iconColor: Colors.green,
              title: '版本 2：不可变 + 手动 copyWith（推荐）',
              subtitle: '所有字段 final，提供 copyWith 方法',
              backgroundColor: Colors.green.shade50,
              textColor: Colors.green.shade900,
              code: '@immutable                                    // ← 注解\n'
                  'class CartItemImmutable {\n'
                  '  final Product product;\n'
                  '  final int quantity;         // ← ✅ 所有字段都是 final\n'
                  '  const CartItemImmutable({...});\n'
                  '\n'
                  '  /// 关键方法：返回修改后的新实例\n'
                  '  CartItemImmutable copyWith({\n'
                  '    Product? product,\n'
                  '    int? quantity,\n'
                  '  }) {\n'
                  '    return CartItemImmutable(\n'
                  '      product: product ?? this.product,\n'
                  '      quantity: quantity ?? this.quantity,\n'
                  '    );\n'
                  '  }\n'
                  '\n'
                  '  // 还需手动实现 == 和 hashCode\n'
                  '}',
            ),
            const SizedBox(height: 8),
            // 版本 3：Freezed 注解驱动
            _buildExpansionTile(
              icon: '\u{1F916}',
              iconColor: Colors.deepPurple,
              title: '版本 3：Freezed 注解驱动（进阶方案）',
              subtitle: '@freezed 注解 → 自动生成 copyWith + == + toString',
              backgroundColor: Colors.deepPurple.shade50,
              textColor: Colors.deepPurple.shade900,
              extraContent: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 12, height: 1.5),
                        children: [
                          TextSpan(
                            text: '💡 Freezed 自动生成：\n',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                '  • copyWith 方法\n'
                                '  • == / hashCode\n'
                                '  • toString\n'
                                '  • JSON 序列化（搭配 json_annotation）\n\n'
                                '版本 2 里手动写的 ~30 行代码，\n'
                                'Freezed 一行 @freezed 注解全部搞定。\n\n'
                                '需要依赖：freezed_annotation + freezed + build_runner\n'
                                '运行命令：dart run build_runner build',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              code: '// 只需要写这些代码：\n'
                  'import \'package:freezed_annotation/freezed_annotation.dart\';\n'
                  'part \'cart_item.freezed.dart\';\n'
                  '\n'
                  '@freezed                        // ← 注解！freeze 指的就是这\n'
                  'class CartItem with _\$CartItem {\n'
                  '  const factory CartItem({\n'
                  '    required Product product,\n'
                  '    @Default(1) int quantity,    // ← @Default 也是注解\n'
                  '  }) = _CartItem;\n'
                  '}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required String icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color textColor,
    required String code,
    Widget? extraContent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: iconColor,
          foregroundColor: Colors.white,
          radius: 16,
          child: Text(icon, style: const TextStyle(fontSize: 14)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: textColor,
                height: 1.5,
              ),
            ),
          ),
          if (extraContent != null) extraContent,
        ],
      ),
    );
  }

  // ---- Section 3: 交互式 Demo -------------------------------------------------
  Widget _buildInteractiveDemo(WidgetRef ref) {
    final immutableItem = ref.watch(demoImmutableProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.touch_app, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  '动手试一试：感受 copyWith 的不可变性',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '下面是一个用 CartItemImmutable（不可变模型）的计数器。\n'
              '每次点 +/- 按钮，copyWith 都会创建一个全新的实例。',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // 状态显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    immutableItem.product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '数量：${immutableItem.quantity}  ×  '
                    '¥${immutableItem.product.price.toStringAsFixed(0)}  =  '
                    '¥${immutableItem.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '实例 hashCode: ${immutableItem.hashCode}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  icon: const Icon(Icons.remove),
                  onPressed: immutableItem.quantity > 1
                      ? () => ref.read(demoImmutableProvider.notifier).decrease()
                      : null,
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${immutableItem.quantity}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () =>
                      ref.read(demoImmutableProvider.notifier).increase(),
                ),
                const SizedBox(width: 24),
                TextButton(
                  onPressed: () =>
                      ref.read(demoImmutableProvider.notifier).reset(),
                  child: const Text('重置'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 关键信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '观察上面的 “实例 hashCode”——每次点击按钮，hashCode 都会变化。\n'
                      '这说明 copyWith 确实创建了一个全新的实例，原实例没有被修改。\n'
                      'Riverpod 通过 “!= 比较引用” 检测变化'
                      ' → 新实例 = 新引用 = 触发重建 ✅',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Section 4: 为什么不可变性对 Riverpod 很重要 ----------------------------
  Widget _buildWhyImmutability(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '为什么 Riverpod 需要不可变数据？',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildConceptRows(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConceptRows() {
    final items = [
      (
        icon: Icons.compare_arrows,
        title: '状态检测机制：引用比较',
        desc:
            'Riverpod 的 state setter 用 != 比较新旧值。'
            'Dart 中 != 默认比较对象引用（内存地址）。'
            '同一个实例 → 引用相同 → != 返回 false'
            ' → 不通知监听者 → UI 不更新。',
      ),
      (
        icon: Icons.warning_amber,
        title: '原地修改的问题',
        desc:
            'cartItem.quantity = 5 只改了对象内部的一个字段，对象引用没变。'
            'Riverpod 认为状态没变化，所以不触发重建。'
            '这就是为什么可变模型会导致 UI 不更新。',
      ),
      (
        icon: Icons.check_circle,
        title: 'copyWith 怎么解决的',
        desc:
            'copyWith 每次都返回一个全新的实例，'
            '新实例 → 新引用 → != 返回 true → '
            'Riverpod 通知所有监听者 → UI 正确重建。',
      ),
      (
        icon: Icons.security,
        title: '不可变性的额外好处',
        desc:
            '线程安全（Dart isolate 场景）、可预测（不会在某处被意外修改）、'
            '易于调试（状态快照天然支持）、易于测试（只需比较值，不用 mock 状态变更）。',
      ),
    ];

    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, size: 20, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.desc,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ---- Section 5: 注解讲解 ----------------------------------------------------
  Widget _buildAnnotationExplainer(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.code, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  '面试官说的 “注解” 是什么意思？',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '在 Dart 中，“注解”（Annotation）是以 @ 开头的元数据标记，'
              '可以附加在类、方法、字段上，告诉编译器、分析器或代码生成器做特定的事情。',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            _buildAnnotationTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnotationTable() {
    final annotations = [
      (
        annotation: '@immutable',
        from: 'package:flutter/foundation.dart (meta)',
        what: 'Dart 分析器检查',
        desc: '标记一个类的所有实例字段必须是 final。\n'
            '如果在这个类里加了非 final 字段，Dart 分析器会在 IDE 里直接报黄线警告。\n'
            '这是 “只读不可改” 的编译级保障。',
      ),
      (
        annotation: '@freezed',
        from: 'package:freezed_annotation',
        what: '代码生成器（build_runner）',
        desc: '告诉 Freezed 代码生成器需要生成 copyWith、==、hashCode、toString 等方法。\n'
            '搭配 factory 构造函数描述数据结构。\n'
            '这就是面试官口中 “freeze” 的核心——注解驱动代码生成。',
      ),
      (
        annotation: '@Default(1)',
        from: 'package:freezed_annotation',
        what: '代码生成器参数',
        desc: '指定字段的默认值。Freezed 的 factory 构造函数不能用 = 设默认值，'
            '所以用 @Default 注解代替。是 Freezed 体系内的辅助注解。',
      ),
      (
        annotation: '@override',
        from: 'dart:core（内置）',
        what: '编译器检查',
        desc: '最常用的注解。告诉编译器 “我在覆盖父类方法”。\n'
            '如果父类没有同名方法，编译器会报错——是一种安全检查。',
      ),
    ];

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FixedColumnWidth(110),
        1: FlexColumnWidth(),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('注解 & 来源',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('含义 & 作用',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        ...annotations.map((a) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.annotation,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.what,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.from,
                      style:
                          const TextStyle(fontSize: 9, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  a.desc,
                  style: const TextStyle(fontSize: 12, height: 1.5),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // ---- Section 6: 为什么不用 Freezed 也没出 Bug？ ----------------------------
  Widget _buildWhyNoFreezedWorks(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.green.shade800),
                const SizedBox(width: 8),
                Text(
                  '常见疑问：为什么不用 @freezed 我的代码也能跑？',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '这是一个很好的追问！答案是：',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            // 解释表格
            ..._buildWhyWorksRows(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 13, height: 1.7),
                  children: [
                    TextSpan(
                      text: '结论：\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'Freezed / copyWith / @immutable 不是「功能必需品」——不用它们代码也能正确运行。\n\n'
                          '它们是「工程质量保障」：\n'
                          '  • 防止团队成员或未来的你写出差错（比如不小心直接赋 quantity）\n'
                          '  • 减少样板代码（Freezed 自动生成 copyWith / == / toString）\n'
                          '  • 让意图明确化（@immutable 就是告诉所有人「这个类不可变」）\n\n'
                          '面试官问这题，考察的是你是否知道这些工程质量实践的存在，\n'
                          '而不仅仅是「把功能实现」的层次。\n'
                          '知道怎么写出「能跑的代码」是基本功，\n'
                          '知道怎么写出「不会出错的代码」才是进阶。',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWhyWorksRows() {
    final rows = [
      (
        title: '1. 你的 Notifier 本身已经在创建新对象',
        desc:
            '你在 CartNotifier.add() 里写的是：\n\n'
            '  state = [...state, CartItem(product: product)]\n\n'
            '这行代码创建了：①一个新的 List  ②一个新的 CartItem。\n'
            '两个都是「新实例」→ 新引用 → Riverpod 检测到变化 ✅\n\n'
            '所以就算 CartItem.quantity 是 mutable 的，\n'
            '只要你不去原地改它，就不会出事。',
      ),
      (
        title: '2. 为什么面试官还要追问？',
        desc:
            '因为这是「靠运气正确」——代码能跑，但模型不设防：\n\n'
            '  • 团队另一个成员可能写 cartItem.quantity = 5\n'
            '  • IDE 不会给任何警告（没有 @immutable 标记）\n'
            '  • Bug 只在运行时才暴露，而且很难排查\n\n'
            '不可变模型 = 让「错误写法」在编译期就被发现。',
      ),
      (
        title: '3. Freezed 的价值在于「省事 + 防错」',
        desc:
            '你的 CartNotifier.add() 里需要手动写：\n\n'
            '  CartItem(product: state[i].product, quantity: state[i].quantity + 1)\n\n'
            '如果 CartItem 有 10 个字段，你要写 10 个参数，漏一个就 Bug。\n'
            '有了 copyWith：\n\n'
            '  state[i].copyWith(quantity: state[i].quantity + 1)\n\n'
            '只需写你真正要改的字段。Freezed 的作用就是自动生成这行 copyWith。',
      ),
    ];

    return rows.map((r) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.arrow_forward, size: 16, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.desc,
                    style: const TextStyle(
                        fontSize: 12, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ---- Section 7: 面试回答模板 ------------------------------------------------
  Widget _buildInterviewAnswer(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                Text(
                  '面试回答模板（建议背诵）',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 13, height: 1.7),
                  children: [
                    TextSpan(
                      text: '面试官：你们项目数据模型有什么设计思路？有没有做只读不可改？\n\n',
                    ),
                    TextSpan(
                      text: '你可以回答：\n\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          '我们的数据模型全部采用不可变设计（Immutable）。\n\n'
                          '所有字段声明为 final，通过 @immutable 注解让 Dart 分析器自动检查。'
                          '要修改数据时，用 copyWith 方法创建一个新实例，原实例不动。\n\n'
                          '在简单模块中我们手动写 copyWith + == + hashCode，'
                          '在复杂模块中使用 Freezed 代码生成——'
                          '通过 @freezed 注解标记数据类，'
                          'build_runner 自动生成 copyWith、==、toString、JSON 序列化等样板代码。\n\n'
                          '这样设计的原因是：Riverpod 通过引用比较检测状态变化，'
                          '只有返回新实例（新引用）才能触发 UI 重建。'
                          '原地修改同一个对象引用，Riverpod 是感知不到的。',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
