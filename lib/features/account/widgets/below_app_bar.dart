import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BelowAppBar extends StatelessWidget {
  const BelowAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Container(
      decoration: const BoxDecoration(
        gradient:
            GlobalVariables.appBarGradient, // Nền gradient đồng bộ với AppBar
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 15, vertical: 10), // Cân đối khoảng cách
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.person,
                color: Colors.grey.shade700), // Biểu tượng đại diện người dùng
          ),
          const SizedBox(width: 10), // Khoảng cách giữa avatar và văn bản
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'Xin chào, ',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onPressed: () {
              // Chuyển hướng đến trang thông tin cá nhân
              Navigator.pushNamed(context, '/update-profile');
            },
          ),
        ],
      ),
    );
  }
}
