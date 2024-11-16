// class ChatModel {
//   String? name;
//   String? icon;
//   bool? isGroup;
//   String? time;
//   String? currentMessage;
//   String? status;
//   bool? select = false;
//   String? id;
//   ChatModel({
//     this.name,
//     this.icon,
//     this.isGroup,
//     this.time,
//     this.currentMessage,
//     this.status,
//     this.select = false,
//     this.id,
//   });
// }

import 'dart:convert';
import 'package:flutter_ecrm/Model/MessageModel.dart';
import 'package:flutter_ecrm/models/user.dart';

class ChatModel {
  final String id;
  final List<User> members;
  final List<MessageModel> messages;
  final MessageModel? lastMessage;
  final int createdAt;

  ChatModel({
    required this.id,
    required this.members,
    required this.messages,
    this.lastMessage,
    required this.createdAt,
  });

  // Chuyển đổi từ Conversation sang Map
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'members': members.map((member) => member.toMap()).toList(),
      'messages': messages.map((message) => message.toMap()).toList(),
      'lastMessage': lastMessage?.toMap(),
      'createdAt': createdAt,
    };
  }

  // Tạo Conversation từ Map
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['_id'] ?? '',
      members: (map['members'] as List<dynamic>)
          .map((member) => User.fromMap(member as Map<String, dynamic>))
          .toList(),
      messages: (map['messages'] as List<dynamic>)
          .map((message) => MessageModel.fromMap(message as Map<String, dynamic>))
          .toList(),
      lastMessage: MessageModel.fromMap(map['lastMessage']),
      createdAt: map['createdAt']?.toInt() ?? 0,
    );
  }

  // Chuyển đổi từ Conversation sang JSON
  String toJson() => json.encode(toMap());

  // Tạo Conversation từ JSON
  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source));

  // Copy với các thuộc tính tùy chọn
  ChatModel copyWith({
    String? id,
    List<User>? members,
    List<MessageModel>? messages,
    MessageModel? lastMessage,
    int? createdAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      members: members ?? this.members,
      messages: messages ?? this.messages,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

