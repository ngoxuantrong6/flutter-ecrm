import 'dart:convert';
import 'dart:developer';

import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter_ecrm/common/widgets/bottom_bar.dart';
import 'package:flutter_ecrm/common/widgets/dialog_alert.dart';
import 'package:flutter_ecrm/common/widgets/loading_show_able.dart';
import 'package:flutter_ecrm/constants/error_handling.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/admin/screens/admin_screen.dart';
import 'package:flutter_ecrm/helper/encryption_helper.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointycastle/api.dart' as encryption;
import 'package:pointycastle/export.dart' as pointy;

class AuthService {
  // sign up user
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      LoadingShowAble.showLoading();
      List<String> divided_hashed_password =
          EncryptionHelper.hashPassword(password);
      encryption.AsymmetricKeyPair keyPair =
          await EncryptionHelper.generateKeyPair();
      pointy.PrivateKey pk = EncryptionHelper.convertStringToPrivateKey(
          EncryptionHelper.convertPrivateKeyToString(
              keyPair.privateKey as pointy.RSAPrivateKey));
      //encrypted_private_key below is stored in database
      String encrypted_private_key = EncryptionHelper.encryptPrivateKey(
          divided_hashed_password[1],
          EncryptionHelper.convertPrivateKeyToString(
              keyPair.privateKey as pointy.RSAPrivateKey));
      //decrypted_private_key below is to be stored in local storage. This key is decrpted upon logging in
      String decrypted_private_key = EncryptionHelper.decryptPrivateKey(
          divided_hashed_password[1], encrypted_private_key);
      User user = User(
        id: '',
        name: name,
        password: divided_hashed_password[0],
        email: email,
        address: '',
        type: '',
        token: '',
        cart: [],
        publicKey: EncryptionHelper.convertPublicKeyToString(
            keyPair.publicKey as pointy.RSAPublicKey),
        privateKey: encrypted_private_key,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'Tài khoản đã được tạo! Đăng nhập với thông tin tương tự!',
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // sign in user
  void signInUser({
    required BuildContext context,
    required String email,
    required String hashedPassword0,
    required String encryption_key,
    bool isFingerPrint = false,
    required List<String> hashedPasswordArg,
  }) async {
    String deviceId = "";
    try {
      LoadingShowAble.showLoading();
      await getDeviceId().then((value) {
        GlobalVariables.DEVICE_ID = value ?? "";
        print("DEVICE_ID: " + GlobalVariables.DEVICE_ID);
      });
      List<String>? hashedPassword = [];
      if (isFingerPrint) {
        await EncryptedSharedPreferences.initialize(key);
        EncryptedSharedPreferences prefs =
            EncryptedSharedPreferences.getInstance();
        hashedPassword = prefs.getStringList('hashedPassword');
      }
      http.Response res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({
          'email': email,
          'password': isFingerPrint ? "" : hashedPassword0,
          'deviceId':
              sha256Convert("${GlobalVariables.DEVICE_ID}bo").toString(),
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          await EncryptedSharedPreferences.initialize(key);
          EncryptedSharedPreferences prefs =
              EncryptedSharedPreferences.getInstance();
          Provider.of<UserProvider>(context, listen: false).setUser(res.body);
          await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
          await prefs.setString('user', jsonEncode(res.body));
          await prefs.setString('userName', jsonDecode(res.body)['name']);
          await prefs.setString('email', jsonDecode(res.body)['email']);
          await prefs.setStringList('hashedPassword',
              isFingerPrint ? hashedPassword : hashedPasswordArg);
          List<String>? passwordHashed = prefs.getStringList('hashedPassword');
          User user = Provider.of<UserProvider>(context, listen: false)
              .user
              .copyWith(
                  privateKey: EncryptionHelper.decryptPrivateKey(
                      isFingerPrint && passwordHashed != []
                          ? passwordHashed![1]
                          : encryption_key,
                      jsonDecode(res.body)['privateKey']));
          if (user.type == 'admin') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AdminScreen.routeName,
              (route) => false,
            );
          } else if (user.type == 'branch') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AdminScreen.routeName,
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              BottomBar.routeName,
              (route) => false,
            );
          }
        },
        onShowInputOTP: () {
          requestOTP(context, email);
          DialogAlert.showMDialogOTP(
            // data.message,
            "",
            context,
            (otpValue) {
              verifyOTP(
                context,
                email: email,
                otp: otpValue,
                deviceId:
                    sha256Convert("${GlobalVariables.DEVICE_ID}bo").toString(),
                hashedPassword0: hashedPassword0,
                encryption_key: encryption_key,
                hashedPasswordArg: hashedPasswordArg,
              );
              // request.setOtpNo = otpValue;
              // request.sessionID = GlobalUtils.ekycSessionId ?? "";
              // login(request, context);
            },
            // onClickResendOTP: () => resendOTPLogin(context,
            //             body: ResendOtpRequest(
            //                 userName: request.username.toUpperCase()))
            //         .then((value) {
            //       if (value.runtimeType == String) {
            //         //dong dialog otp
            //         Navigator.of(context).pop();
            //         DialogShow.showAlertDialog(context, content: value);
            //       }
            //     },
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get user data
  void getUserData(
    BuildContext context,
  ) async {
    try {
      await EncryptedSharedPreferences.initialize(key);
      EncryptedSharedPreferences prefs =
          EncryptedSharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token!
        },
      );

      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        http.Response userRes = await http.get(
          Uri.parse('$uri/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token
          },
        );

        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void requestOTP(
    BuildContext context,
    String email,
  ) async {
    try {
      LoadingShowAble.showLoading();
      var otpRes = await http.post(
        Uri.parse('$uri/api/request-otp'),
        body: jsonEncode({
          'email': email,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      var response = jsonDecode(otpRes.body);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void verifyOTP(
    BuildContext context, {
    required String email,
    dynamic otp,
    required String deviceId,
    required String hashedPassword0,
    required String encryption_key,
    required List<String> hashedPasswordArg,
  }) async {
    try {
      LoadingShowAble.showLoading();
      http.Response res = await http.post(
        Uri.parse('$uri/api/verify-otp'),
        body: jsonEncode({
          'email': email,
          'otp': otp.toString(),
          'deviceId': deviceId,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          if (jsonDecode(res.body)['msg'] == "Xác minh thành công!") {
            signInUser(
              context: context,
              email: email,
              hashedPassword0: hashedPassword0,
              encryption_key: encryption_key,
              hashedPasswordArg: hashedPasswordArg,
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
