import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import 'package:trade_interfaces/trade_interfaces.dart';
import '../src/goods_service_impl.dart';

/// 商品详情页
class GoodsDetailScreen extends StatelessWidget {
  final String goodsId;
  const GoodsDetailScreen({super.key, required this.goodsId});

  @override
  Widget build(BuildContext context) {
    final service = GoodsServiceImpl();

    return TechDetailShell(
      title: '商品详情',
      child: FutureBuilder<GoodsItem>(
        future: service.getGoodsById(goodsId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }
          final goods = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.shopping_bag, size: 64, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Text(goods.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(goods.priceText,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.red, fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('库存: ${goods.stock} 件'),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('加入购物车'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
