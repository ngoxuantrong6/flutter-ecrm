import 'dart:convert';

import 'package:flutter_ecrm/models/product.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? messageEncryptForMe;
  final String? messageEncryptForReveiver;
  final String? image;
  final Product? product;
  final int createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.messageEncryptForMe,
    this.messageEncryptForReveiver,
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
      'messageEncryptForMe': messageEncryptForMe,
      'messageEncryptForReveiver': messageEncryptForReveiver,
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
      messageEncryptForMe: map['messageEncryptForMe'] ?? '',
      messageEncryptForReveiver: map['messageEncryptForReveiver'] ?? '',
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
    String? messageEncryptForMe,
    String? messageEncryptForReveiver,
    String? image,
    Product? product,
    int? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      messageEncryptForMe: messageEncryptForMe ?? this.messageEncryptForMe,
      messageEncryptForReveiver: messageEncryptForReveiver ?? this.messageEncryptForReveiver,
      image: image ?? this.image,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

