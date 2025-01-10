import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/providers/common_provider.dart';
import 'package:one_context/one_context.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import 'core_toast.dart';

typedef ValueOtp<String> = String Function(String);

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class DialogAlert {
  //  alert dành cho nhập otp login
  // ignore: inference_failure_on_function_return_type
  static showMDialogOTP(
      String messanger, BuildContext context, ValueOtp valueOtp,
      {bool visibleInput = false, Function? onClickResendOTP}) async {
    TextEditingController textEditingController;

    if (Platform.isAndroid) {
      textEditingController = OTPTextEditController(
        codeLength: 6,
        onCodeReceive: (code) => print('Your Application receive code - $code'),
      )..startListenUserConsent(
          (code) {
            //Chỗ này đang regex chuỗi có 3 ký tự là số (test để 3, thật để 6)
            final exp = RegExp(r'(\d{6})');
            return exp.stringMatch(code ?? '') ?? '';
          },
        );
    } else {
      textEditingController = TextEditingController();
    }

    // ByteData byteData = await rootBundle.load(Assets.imagesBgLoginTop);
    // Uint8List list = byteData.buffer.asUint8List();
    // ByteData byteData2 = await rootBundle.load(Assets.imagesBgLoginTop);
    // Uint8List list2 = byteData2.buffer.asUint8List();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString(Utility.KEY, Utility.base64String(list));
    // await prefs.setString(Utility.KEY_BACKGROUND, Utility.base64String(list2));
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DialogWidgetTwoButtonCustom(
            title: "Xác thực đăng nhập",
            widget: visibleInput == true
                ? Expanded(
                    child: Center(
                      child: Text(
                        messanger,
                        textAlign: TextAlign.center,
                        // style: bodyTextApiSandboxRegular.copyWith(
                        //     fontSize: fontSize14),
                      ),
                    ),
                  )
                : ChangeNotifierProvider(
                    create: (context) => CommonProvider(),
                    builder: (context, child) {
                      CommonProvider presenter =
                          Provider.of<CommonProvider>(context);
                      // presenter.startCountTimeResendOTP(context);
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: PinCodeTextField(
                              appContext: context,
                              pinTheme: PinTheme(
                                fieldWidth: 20,
                                fieldHeight: 30,
                                shape: PinCodeFieldShape.underline,
                                activeColor: GlobalVariables.primaryColor,
                                inactiveColor: Colors.grey,
                              ),
                              length: 6,
                              autoFocus: true,
                              // textStyle: textStyleDefault.copyWith(
                              //     fontSize: fontSize16),
                              keyboardType: TextInputType.number,
                              controller: textEditingController,
                              onChanged: (String value) {},
                              onCompleted: (value) {},
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (messanger.isNotEmpty)
                            Container(
                              // color: colorEaf7ff,
                              margin:
                                  const EdgeInsets.only(left: 20, right: 20),
                              // padding: EdgeInsets.symmetric(vertical: width_40),
                              child: Center(
                                child: Text(
                                  messanger,
                                  textAlign: TextAlign.center,
                                  // style: bodyTextApiSandboxRegular.copyWith(
                                  //     fontSize: fontSize14, height: 1.5),
                                ),
                              ),
                            )
                          else
                            const SizedBox(),
                          const SizedBox(height: 10),
                          // Text(
                          //   "${"Mã OTP sẽ hết hạn sau"}${" ${presenter.timeCountResendOTP}s"}",
                          //   // style: textStyleBoldDefault.copyWith(
                          //   //   fontSize: fontSize14,
                          //   //   height: 1.5,
                          //   //   fontWeight: FontWeight.bold,
                          //   //   decoration: TextDecoration.underline,
                          //   //   color: presenter.isDisable
                          //   //       ? colorGrey
                          //   //       : colorPrimary,
                          //   // ),
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Text(
                          //       "Không nhận được mã xác nhận?",
                          //       textAlign: TextAlign.end,
                          //       // style: textStyleDefault.copyWith(
                          //       //     fontSize: fontSize14, height: 1.5),
                          //     ),
                          //     const SizedBox(width: 20),
                          //     InkWell(
                          //       onTap: () async {
                          //         if (onClickResendOTP != null &&
                          //             !presenter.isDisable) {
                          //           await onClickResendOTP();
                          //           presenter.startCountTimeResendOTP(context);
                          //         }
                          //       },
                          //       splashFactory: presenter.isDisable
                          //           ? NoSplash.splashFactory
                          //           : null,
                          //       child: Text(
                          //         " ${"internal-transfer.resend_otp".tr()}${presenter.isDisable ? " (${presenter.timeCountResendOTP}s)" : ""}",
                          //         // style: textStyleBoldDefault.copyWith(
                          //         //   fontSize: fontSize14,
                          //         //   height: 1.5,
                          //         //   fontWeight: FontWeight.bold,
                          //         //   decoration: TextDecoration.underline,
                          //         //   color: presenter.isDisable
                          //         //       ? colorGrey
                          //         //       : colorPrimary,
                          //         // ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      );
                    }),
            contextDialog: context,
            onClickSubmit: () {
              if (Platform.isAndroid &&
                  textEditingController is OTPTextEditController) {
                textEditingController.stopListen();
                if (visibleInput == false) {
                  if (textEditingController.text != "") {
                    valueOtp(textEditingController.text);
                    Navigator.of(context).pop({textEditingController.text});
                  } else {
                    Toast.showLongTop("Quý khách vui lòng nhập mã OTP!");
                  }
                } else {
                  Navigator.of(context).pop();
                }
              } else {
                if (visibleInput == false) {
                  if (textEditingController.text != "") {
                    valueOtp(textEditingController.text);
                    Navigator.of(context).pop({textEditingController.text});
                  } else {
                    Toast.showLongTop("Quý khách vui lòng nhập mã OTP!");
                  }
                } else {
                  Navigator.of(context).pop();
                }
              }
            },
          );
        });
  }
}

class DialogWidgetTwoButtonCustom extends StatefulWidget {
  final String? title;
  final String? content;
  final Function? onClickSubmit;
  final Function? onClickCancel;
  final String? textSubmit;
  final String? textCancel;
  final BuildContext? contextDialog;
  final bool? isTranslateContent;
  final Widget? widget;

  const DialogWidgetTwoButtonCustom({
    Key? key,
    this.title,
    this.content,
    this.onClickSubmit,
    this.onClickCancel,
    this.textSubmit,
    this.textCancel,
    this.contextDialog,
    this.isTranslateContent = true,
    this.widget,
  }) : super(key: key);

  @override
  State<DialogWidgetTwoButtonCustom> createState() =>
      _DialogWidgetTwoButtonCustomState();
}

class _DialogWidgetTwoButtonCustomState
    extends State<DialogWidgetTwoButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: ListView(
        shrinkWrap: true,
        primary: false,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Center(
                child: Text(
              widget.title ?? "",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
          widget.widget ?? const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: widget.textSubmit ?? "Tiếp tục",
              onTap: () {
                if (widget.onClickSubmit != null) {
                  widget.onClickSubmit!();
                } else {
                  Navigator.pop(widget.contextDialog!);
                }
              },
            ),
          ),
          const SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}
