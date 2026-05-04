import 'dart:convert';

import 'package:flutter_ecrm/models/product.dart';

class Order {
  final String id;
  final List<Product> products;
  final List<int> quantity;
  final String address;
  final String userId;
  final int orderedAt;
  final int status;
  final int totalPrice;
  Order({
    required this.id,
    required this.products,
    required this.quantity,
    required this.address,
    required this.userId,
    required this.orderedAt,
    required this.status,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'products': products.map((x) => x.toMap()).toList(),
      'quantity': quantity,
      'address': address,
      'userId': userId,
      'orderedAt': orderedAt,
      'status': status,
      'totalPrice': totalPrice,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    final productsData = map['products'] as List<dynamic>? ?? [];
    return Order(
      id: map['_id'] ?? '',
      products: productsData
          .where((x) => x != null && x['product'] != null)
          .map((x) => Product.fromMap(x['product'] as Map<String, dynamic>))
          .toList(),
      quantity: productsData
          .where((x) => x != null && x['product'] != null)
          .map((x) => (x['quantity'] as num?)?.toInt() ?? 0)
          .toList(),
      address: map['address'] ?? '',
      userId: map['userId'] ?? '',
      orderedAt: map['orderedAt']?.toInt() ?? 0,
      status: map['status']?.toInt() ?? 0,
      totalPrice: map['totalPrice']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));
}
