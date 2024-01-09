import 'package:flutter/material.dart';

class PopupNotificationCustom {
  static Future<bool?> showMessgae(
      {required BuildContext context,
      required String title,
      required String message,
      String? buttonTitleLeft,
      String? buttonTitleRight,
      Color? colorTitleLeft = Colors.black,
      Color? colorTitleRight = Colors.black,
      VoidCallback? pressButtonLeft,
      VoidCallback? pressButtonRight,
      bool? hiddenButtonLeft = false,
      bool? hiddenButtonRight = false,
      TextAlign? textAlign,
      Alignment? alignment,
      bool barrierDismissible = false}) async {
    return showDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return AlertDialog(
              insetPadding: const EdgeInsets.all(48),
              contentPadding: const EdgeInsets.all(0),
              scrollable: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              content: Column(
                children: [
                  Container(
                    alignment: alignment ?? Alignment.center,
                    margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Text(
                      title,
                      textAlign: textAlign ?? TextAlign.center,
                      // style: FONT_CONST.medium(
                      //     color: COLOR_CONST.cloudBurst, fontSize: 14),
                    ),
                  ),
                  Container(
                    alignment: alignment ?? Alignment.center,
                    margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
                    child: Text(
                      message,
                      textAlign: textAlign ?? TextAlign.center,
                      // style: FONT_CONST.medium(
                      //     color: COLOR_CONST.cloudBurst, fontSize: 14),
                    ),
                  ),
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1, color: Colors.black),
                      ),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (hiddenButtonLeft == false)
                            Expanded(
                                flex: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    if (pressButtonLeft != null) {
                                      pressButtonLeft();
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Text(
                                        buttonTitleLeft ?? "Đồng ý",
                                        // style: FONT_CONST.medium(
                                        //     color: colorTitleLeft,
                                        //     fontSize: 14),
                                      ),
                                    ),
                                  ),
                                )),
                          if (hiddenButtonLeft == false &&
                              hiddenButtonRight == false)
                            Container(
                              color: Colors.black,
                              width: 1,
                              height: 39,
                            ),
                          if (hiddenButtonRight == false)
                            Expanded(
                                flex: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    if (pressButtonRight != null) {
                                      pressButtonRight();
                                    }
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Text(
                                        buttonTitleRight ?? "Hủy",
                                        // style: FONT_CONST.medium(
                                        //     color: colorTitleRight,
                                        //     fontSize: 14),
                                      ),
                                    ),
                                  ),
                                )),
                        ]),
                  )
                ],
              ));
        });
  }
}
