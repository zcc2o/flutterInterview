import 'package:flutter/material.dart';
import 'package:interview_widgets/interview_widgets.dart';
import 'package:trade_interfaces/trade_interfaces.dart';
import '../src/order_service_impl.dart';

/// 订单详情页
///
/// 依赖的是 trade_interfaces 中的 IGoodsService，不是 goods 包
class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  final IGoodsService goodsService;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.goodsService,
  });

  @override
  Widget build(BuildContext context) {
    final orderService = OrderServiceImpl(goodsService);

    return TechDetailShell(
      title: '订单详情（接口解耦）',
      child: FutureBuilder<OrderDetail>(
        future: orderService.getOrderDetail(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }

          final detail = snapshot.data!;
          final order = detail.order;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoRow(label: '订单号', value: order.id),
              _InfoRow(label: '客户', value: order.customerName),
              _InfoRow(label: '下单时间', value: '2026-07-15'),
              const Divider(height: 32),
              Text('商品明细', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...detail.goodsItems.map((goods) {
                final orderItem = order.items.firstWhere(
                  (item) => item.goodsId == goods.id,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: Text(goods.name),
                    subtitle: Text('${goods.priceText} × ${orderItem.quantity}'),
                    trailing: Text(
                      '¥${orderItem.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              }),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('合计: ', style: Theme.of(context).textTheme.titleLarge),
                  Text(order.totalText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.red, fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
