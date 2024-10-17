import 'dart:convert';

class Branch {
  final String branchName;
  final String address;
  final String? id;
  final String email;
  final String password;
  Branch({
    required this.branchName,
    required this.address,
    this.id,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'branchName': branchName,
      'address': address,
      '_id': id,
      'email': email,
      'password': password,
    };
  }

  factory Branch.fromMap(Map<String, dynamic> map) {
    return Branch(
      branchName: map['branchName'] ?? '',
      address: map['address'] ?? '',
      id: map['_id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Branch.fromJson(String source) =>
      Branch.fromMap(json.decode(source));
}
