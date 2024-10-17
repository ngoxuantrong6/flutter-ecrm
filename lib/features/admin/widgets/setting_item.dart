import 'package:flutter/material.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingItem extends StatelessWidget {
  const SettingItem(
      {Key? key,
      this.heightIcon,
      this.widthIcon,
      this.isArrowNext = true,
      this.isSwitch = false,
      required this.iconPath,
      this.title = '',
      this.onTap})
      : super(key: key);
  final double? heightIcon;
  final double? widthIcon;
  final bool isArrowNext;
  final bool isSwitch;
  final IconData iconPath;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    gradient: GlobalVariables.appBarGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(iconPath),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text(
                      title,
                      textAlign: TextAlign.start,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                if (isArrowNext)
                  Container(
                    margin: EdgeInsets.only(left: 15, top: 5),
                    child: Icon(Icons.keyboard_arrow_right, size: 26),
                  )
                else
                  Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
