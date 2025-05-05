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
    // đăng ký tài khoản
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      LoadingShowAble
          .showLoading(); // hiển thị một màn hình cho người dùng để thông báo
      List<String> divided_hashed_password = EncryptionHelper.hashPassword(
          password); // mật khẩu người dùng nhập vào được mã hóa phương thức hashPassword từ EncryptionHelper
      encryption.AsymmetricKeyPair keyPair = await EncryptionHelper
          .generateKeyPair(); // tạo cặp khóa bất đối xứng dùng thuật toán RSA
      pointy.PrivateKey pk = EncryptionHelper.convertStringToPrivateKey(
          EncryptionHelper.convertPrivateKeyToString(keyPair.privateKey as pointy
              .RSAPrivateKey)); // chuyển đổi private key . chuyển đổi khóa riêng private key từ dạng đối tượng RSAprivarky sang dạng chuỗi sau đó chuyển lại thành một đối tượng private key có thể sử dụng

      //encrypted_private_key below is stored in database
      String encrypted_private_key = EncryptionHelper.encryptPrivateKey(
          divided_hashed_password[1],
          EncryptionHelper.convertPrivateKeyToString(keyPair.privateKey as pointy
              .RSAPrivateKey)); // mã hóa private key được mã hóa với key thứ 2 lấy từ divided_hashed_password
      //decrypted_private_key below is to be stored in local storage. This key is decrpted upon logging in
      String decrypted_private_key = EncryptionHelper.decryptPrivateKey(
          divided_hashed_password[1],
          encrypted_private_key); //Giải mã private key: Để sử dụng private key trong các bước tiếp theo (ví dụ: khi đăng nhập), khóa riêng phải được giải mã bằng "key" thứ hai.
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
    String deviceId =
        ""; // khởi tạo 1 biến deviceID rỗng để lưu ID của thiết bị
    try {
      LoadingShowAble
          .showLoading(); // tạo loading để load , để thông báo cho người dùng rằng ứng dụng đang được thực hiện một tác vụ
      await getDeviceId().then((value) {
        // gọi hàm getDeviedId để lấy ID của thiết bị , có thể tự động nhận diện khi người dùng thực hiện đăng nhập
        GlobalVariables.DEVICE_ID = value ?? "";
        print("DEVICE_ID: " + GlobalVariables.DEVICE_ID);
      });
      List<String>? hashedPassword = []; // xử lý đăng nhập bằng vân vay
      if (isFingerPrint) {
        // nếu dùng xác thực vân tay
        await EncryptedSharedPreferences.initialize(
            key); // khởi tạo để làm việc với dữ liệu đã mã hóa trong bộ nhớ
        EncryptedSharedPreferences prefs =
            EncryptedSharedPreferences.getInstance();
        hashedPassword = prefs.getStringList(
            'hashedPassword'); // lấy danh sách mật khẩu đã mã hóa từ sharePreferences
      }
      http.Response res = await http.post(
        // gửi yêu cầu đăng nhập đến backend
        Uri.parse('$uri/api/signin'), // gửi POST đến api đăng nhập
        body: jsonEncode({
          'email': email,
          'password': isFingerPrint
              ? ""
              : hashedPassword0, // nếu đăng nhập bằng vân tay thì pass == nuill. còn không mật khẩu đã mã hóa hashedPasssword0 sẽ được gửi
          'deviceId': sha256Convert("${GlobalVariables.DEVICE_ID}bo")
              .toString(), // mã hóa deviceId bằng thuật toán SHA-256 để bảo mật và làm cho nó trở thành một giá trị duy nhât cho một thiết bị
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
