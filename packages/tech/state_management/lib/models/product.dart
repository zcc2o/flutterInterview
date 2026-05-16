class Product {
  final String id;
  final String name;
  final String category;
  final double price;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

class Order {
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;

  const Order({
    required this.items,
    required this.total,
    required this.createdAt,
  });
}

const kProducts = [
  Product(id: '1', name: 'iPhone 17', category: '电子产品', price: 6999),
  Product(id: '2', name: 'MacBook Pro', category: '电子产品', price: 14999),
  Product(id: '3', name: 'AirPods Pro', category: '电子产品', price: 1899),
  Product(id: '4', name: 'Swift 编程', category: '图书', price: 89),
  Product(id: '5', name: 'Flutter 实战', category: '图书', price: 79),
  Product(id: '6', name: '人体工学椅', category: '家具', price: 3299),
  Product(id: '7', name: '升降桌', category: '家具', price: 2499),
  Product(id: '8', name: '机械键盘', category: '电子产品', price: 699),
  Product(id: '9', name: 'Dart 权威指南', category: '图书', price: 99),
  Product(id: '10', name: '显示器支架', category: '家具', price: 459),
];

const kCategories = ['全部', '电子产品', '图书', '家具'];

const kTaxRate = 0.13;
