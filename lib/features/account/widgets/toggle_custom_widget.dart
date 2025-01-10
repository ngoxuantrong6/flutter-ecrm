import 'package:flutter/material.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';

class ToggleCustomWidget extends StatelessWidget {
  final bool value;

  const ToggleCustomWidget({Key? key, required this.value}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 25,
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: GlobalVariables.primaryColor),
        borderRadius: BorderRadius.circular(50),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment:
            !value ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: GlobalVariables.primaryColor),
          )
        ],
      ),
    );
  }
}
