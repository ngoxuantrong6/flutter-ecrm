import 'dart:convert';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter_ecrm/common/widgets/popup_notification_custom.dart';
import 'package:flutter_ecrm/common/widgets/loading_show_able.dart';
import 'package:flutter_ecrm/constants/error_handling.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/auth/screens/auth_screen.dart';
import 'package:flutter_ecrm/models/order.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AccountServices {
  Future<List<Order>> fetchMyOrders({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];
    try {
      http.Response res =
          await http.get(Uri.parse('$uri/api/orders/me'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            orderList.add(
              Order.fromJson(
                jsonEncode(
                  jsonDecode(res.body)[i],
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return orderList;
  }

  void updateProfile({
    required BuildContext context,
    required String userName,
    required String address,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      LoadingShowAble.showLoading();

      User user = User(
        id: userProvider.user.id,
        name: userName,
        email: userProvider.user.email,
        password: userProvider.user.password,
        address: address,
        type: userProvider.user.type,
        token: userProvider.user.token,
        cart: userProvider.user.cart,
        publicKey: userProvider.user.publicKey,
        privateKey: userProvider.user.privateKey,
      );

      http.Response res = await http.patch(
        Uri.parse('$uri/api/update-profile'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: user.toJson(),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          User user = userProvider.user.copyWith(
            name: jsonDecode(res.body)['name'],
            address: jsonDecode(res.body)['address'],
          );
          userProvider.setUserFromModel(user);
          showSnackBar(context, 'Cập nhật thông tin của bạn thành công!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void changePassword({
    required BuildContext context,
    required String oldPassword,
    required String newPassword,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      LoadingShowAble.showLoading();

      http.Response res = await http.patch(
        Uri.parse('$uri/api/change-password'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          User user = userProvider.user.copyWith(
            password: jsonDecode(res.body)['password'],
          );
          userProvider.setUserFromModel(user);
          PopupNotificationCustom.showMessgae(
                  context: context,
                  title: 'ĐỔI MẬT KHẨU THÀNH CÔNG',
                  message:
                      'Mật khẩu của bạn đã được đổi thành công. Bạn cần đăng nhập lại để tiếp tục sử dụng dịch vụ',
                  buttonTitleLeft: "Đăng xuất",
                  hiddenButtonRight: true)
              .then((value) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AuthScreen.routeName,
              (route) => false,
            );
          });
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void logOut(BuildContext context) async {
    try {
      await EncryptedSharedPreferences.initialize(key);
      EncryptedSharedPreferences sharedPreferences = EncryptedSharedPreferences.getInstance();
      await sharedPreferences.setString('x-auth-token', '');
      await sharedPreferences.setString('user', '');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AuthScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
