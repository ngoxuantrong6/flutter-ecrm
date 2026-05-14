import 'dart:convert';

class Branch {
  final String branchName;
  final String address;
  final String? id;
  final String email;
  final String password;
  final String publicKey;
  final String privateKey;
  final int? provinceId;
  final int? wardId;
  Branch({
    required this.branchName,
    required this.address,
    this.id,
    required this.email,
    required this.password,
    this.publicKey = '',
    this.privateKey = '',
    this.provinceId,
    this.wardId,
  });

  Map<String, dynamic> toMap() {
    return {
      'branchName': branchName,
      'address': address,
      '_id': id,
      'email': email,
      'password': password,
      'publicKey': publicKey,
      'privateKey': privateKey,
      'provinceId': provinceId,
      'wardId': wardId,
    };
  }

  factory Branch.fromMap(Map<String, dynamic> map) {
    return Branch(
      branchName: map['branchName'] ?? '',
      address: map['address'] ?? '',
      id: map['_id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      publicKey: map['publicKey'] ?? '',
      privateKey: map['privateKey'] ?? '',
      provinceId: map['provinceId'] != null ? (map['provinceId'] as num).toInt() : null,
      wardId: map['wardId'] != null ? (map['wardId'] as num).toInt() : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Branch.fromJson(String source) => Branch.fromMap(json.decode(source));
}
