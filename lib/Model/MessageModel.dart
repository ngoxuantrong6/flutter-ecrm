// class MessageModel {
//   String? type;
//   String? message;
//   String? time;
//   MessageModel({this.message, this.type, this.time});
// }

import 'dart:convert';

import 'package:flutter_ecrm/models/product.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? message;
  final String? image;
  final Product? product;
  final int createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.image,
    this.product,
    required this.createdAt,
  });

  // Chuyển đổi từ Message sang Map
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'image': image,
      'product': product,
      'createdAt': createdAt,
    };
  }

  // Tạo Message từ Map
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['_id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      image: map['image'] ?? '',
      product: map['product'] != null ? Product.fromMap(map['product']) : null,
      createdAt: map['createdAt']?.toInt() ?? 0,
    );
  }

  // Chuyển đổi từ Message sang JSON
  String toJson() => json.encode(toMap());

  // Tạo Message từ JSON
  factory MessageModel.fromJson(String source) => MessageModel.fromMap(json.decode(source));

  // Copy với các thuộc tính tùy chọn
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    String? image,
    Product? product,
    int? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      image: image ?? this.image,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

