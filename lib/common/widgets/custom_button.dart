import 'package:flutter/material.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: color == null ? GlobalVariables.appBarGradient : null,
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color == null ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
