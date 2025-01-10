import 'package:flutter_ecrm/common/widgets/popup_notification_custom.dart';
import 'package:flutter_ecrm/features/account/screens/change_password_screen.dart';
import 'package:flutter_ecrm/features/account/screens/register_biometric_screen.dart';
import 'package:flutter_ecrm/features/account/screens/update_profile_screen.dart';
import 'package:flutter_ecrm/features/account/services/account_services.dart';
import 'package:flutter_ecrm/features/account/widgets/below_app_bar.dart';
import 'package:flutter_ecrm/features/account/widgets/top_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/features/admin/widgets/setting_item.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BelowAppBar(),
            const SizedBox(height: 20),
            SettingItem(
              title: "Thông tin cá nhân",
              iconPath: Icons.person_outline_outlined,
              onTap: () {
                Navigator.pushNamed(context, UpdateProfileScreen.routeName);
              },
            ),
            SettingItem(
              title: "Cài đặt đăng nhập FaceID/ vân tay",
              iconPath: Icons.fingerprint_outlined,
              onTap: () {
                Navigator.pushNamed(context, RegisterBiometricScreen.routeName);
              },
            ),
            SettingItem(
              title: "Đổi mật khẩu",
              iconPath: Icons.lock_outline,
              onTap: () {
                Navigator.pushNamed(context, ChangePasswordScreen.routeName);
              },
            ),
            SettingItem(
              title: "Đăng xuất",
              iconPath: Icons.logout_outlined,
              isArrowNext: false,
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
      ),
    );
  }
}
