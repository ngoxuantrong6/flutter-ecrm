import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    required this.title,
    required this.pressAgreeButton,
  }) : super(key: key);
  final String title;
  final VoidCallback pressAgreeButton;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        insetPadding: const EdgeInsets.all(48),
        contentPadding: const EdgeInsets.all(0),
        scrollable: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        content: Column(
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Container(
              height: 40,
              margin: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: () {
                            pressAgreeButton();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: const Center(
                              child: Text(
                                "Đồng ý",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        )),
                    Container(
                      width: 1,
                      color: Colors.black,
                      height: 39,
                    ),
                    Expanded(
                        flex: 5,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: const Center(
                              child: Text(
                                "Hủy",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        )),
                  ]),
            )
          ],
        ));
  }
}
