import 'dart:async';

import 'package:flutter/material.dart';

class CommonProvider extends ChangeNotifier {
  int timeCountResendOTP = 60;
  int countResendOTP = 0;

  late Timer timer;

  bool isDisable = false;

  void startCountTimeResendOTP(BuildContext context) {
    const oneSec = const Duration(seconds: 1);
    timeCountResendOTP = 60;
    isDisable = true;
    notifyListeners();
    timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (timeCountResendOTP == 0) {
          timer.cancel();
          isDisable = false;
        } else {
          timeCountResendOTP--;
        }
        notifyListeners();
      },
    );
  }
}