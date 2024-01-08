import 'package:flutter/material.dart';

class CustomTextFieldLabel extends StatelessWidget {
  const CustomTextFieldLabel({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        borderRadius: BorderRadius.circular(5),
        color: Colors.black12.withOpacity(0.1),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          email,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
