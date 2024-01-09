import 'package:amazon_clone_tutorial/common/widgets/popup_notification_custom.dart';
import 'package:amazon_clone_tutorial/features/account/screens/change_password_screen.dart';
import 'package:amazon_clone_tutorial/features/account/screens/my_orders_screen.dart';
import 'package:amazon_clone_tutorial/features/account/screens/update_profile_screen.dart';
import 'package:amazon_clone_tutorial/features/account/services/account_services.dart';
import 'package:amazon_clone_tutorial/features/account/widgets/account_button.dart';
import 'package:flutter/material.dart';

class TopButtons extends StatelessWidget {
  const TopButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AccountButton(
              text: 'Đơn hàng của tôi',
              onTap: () {
                Navigator.pushNamed(context, MyOrdersScreen.routeName);
              },
            ),
            AccountButton(
              text: 'Thông tin cá nhân',
              onTap: () {
                Navigator.pushNamed(context, UpdateProfileScreen.routeName);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            AccountButton(
              text: 'Đổi mật khẩu',
              onTap: () {
                Navigator.pushNamed(context, ChangePasswordScreen.routeName);
              },
            ),
            AccountButton(
              text: 'Đăng xuất',
              onTap: () {
                PopupNotificationCustom.showMessgae(
                  context: context,
                  title: 'ĐĂNG XUẤT',
                  message: 'Bạn có thực sự muốn thoát phiên đăng nhập này?',
                  pressButtonLeft: () => AccountServices().logOut(context),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
