import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_ecrm/common/widgets/popup_notification_custom.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/account/widgets/toggle_custom_widget.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:permission_handler/permission_handler.dart';

class RegisterBiometricScreen extends StatefulWidget {
  static const String routeName = '/register-biometric-screen';
  const RegisterBiometricScreen({Key? key}) : super(key: key);

  @override
  State<RegisterBiometricScreen> createState() =>
      _RegisterBiometricScreenState();
}

class _RegisterBiometricScreenState extends State<RegisterBiometricScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool valueSelected = false;

  Future<void> toggleButtonBiometric(BuildContext context) async {
    await funcFingerPrint(context);
  }

  Future<void> funcFingerPrint(BuildContext context) async {
    bool isAuthorized = false;
    const iosStrings = IOSAuthMessages(
      cancelButton: 'Hủy',
      goToSettingsButton: 'Cài đặt',
      goToSettingsDescription: 'Vui lòng thiết lập Touch ID/Face ID của bạn.',
      lockOut: 'Vui lòng kích hoạt Touch ID/Face ID của bạn.',
    );
    const andStrings = AndroidAuthMessages(
      cancelButton: 'Hủy',
      goToSettingsButton: 'Cài đặt',
      goToSettingsDescription: 'Vui lòng thiết lập Touch ID/Face ID của bạn.',
      signInTitle: 'Xác minh Touch ID/Face ID của bạn.',
    );
    try {
      isAuthorized = await _localAuthentication.authenticate(
        localizedReason: "Vui lòng xác thực để đăng nhập",
        authMessages: <AuthMessages>[andStrings, iosStrings],
        options: const AuthenticationOptions(
          useErrorDialogs: false,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print("PlatformException ${e.code}");
      final bool canAuthenticateWithBiometrics =
          await _localAuthentication.canCheckBiometrics;
      if (!canAuthenticateWithBiometrics) {
        PopupNotificationCustom.showMessgae(
          context: context,
          title: 'THÔNG BÁO',
          message:
              'Quý khách vui lòng cho phép ứng dụng eCRM Pro truy cập FaceID để sử dụng tính năng này!',
          pressButtonLeft: () async {
            await openAppSettings();
          },
        );
        return;
      }

      if (e.code == auth_error.passcodeNotSet) {
        PopupNotificationCustom.showMessgae(
          context: context,
          title: 'THÔNG BÁO',
          message:
              'Thao tác đã bị hủy vì cảm biến sinh trắc học không khả dụng!',
          buttonTitleLeft: "Đồng ý",
          hiddenButtonRight: true,
        );
      } else if (e.code == auth_error.lockedOut) {
        PopupNotificationCustom.showMessgae(
          context: context,
          title: 'THÔNG BÁO',
          message: 'Thao tác đã bị khóa tạm thời do thử quá nhiều lần!',
          buttonTitleLeft: "Đồng ý",
          hiddenButtonRight: true,
        );
      } else if (e.code == auth_error.notEnrolled) {
        PopupNotificationCustom.showMessgae(
          context: context,
          title: 'THÔNG BÁO',
          message: 'Thiết bị chưa được đăng ký bảo mật vân tay/Face ID!',
          buttonTitleLeft: "Đồng ý",
          hiddenButtonRight: true,
        );
      } else if (e.code == auth_error.permanentlyLockedOut) {
        PopupNotificationCustom.showMessgae(
          context: context,
          title: 'THÔNG BÁO',
          message: 'Thao tác đã bị hủy vì xảy ra quá nhiều lần sai!',
          buttonTitleLeft: "Đồng ý",
          hiddenButtonRight: true,
        );
      } else if (e.code == auth_error.notAvailable) {
        PopupNotificationCustom.showMessgae(
          context: context,
          title: 'THÔNG BÁO',
          message:
              'Thao tác đã bị hủy vì bảo mật vân tay/Face ID không khả dụng!',
          buttonTitleLeft: "Đồng ý",
          hiddenButtonRight: true,
        );
      } else {
        PopupNotificationCustom.showMessgae(
          context: context,
          title: 'THÔNG BÁO',
          message:
              'Không thành công. Vui lòng kiểm tra lại bảo mật vân tay/Face ID trên thiết bị!',
          buttonTitleLeft: "Đồng ý",
          hiddenButtonRight: true,
        );
      }

      _localAuthentication.stopAuthentication();
    }
    _localAuthentication.stopAuthentication();

    if (isAuthorized) {
      handleSaveBiometric();
    }
  }

  @override
  void initState() {
    getBiometric();
    super.initState();
  }

  void handleSaveBiometric() async {
    setState(() {
      valueSelected = !valueSelected;
    });
    await EncryptedSharedPreferences.initialize(key);
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    await prefs.setBoolean('biometric', valueSelected);
  }

  void getBiometric() async {
    await EncryptedSharedPreferences.initialize(key);
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    setState(() {
      valueSelected = prefs.getBoolean('biometric') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: ((context, orientation) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: GlobalVariables.appBarGradient,
                ),
              ),
              title: const Text(
                'Cài đặt đăng nhập FaceID/ vân tay',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    "Đăng nhập bằng vân tay hoặc FaceID",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                      onTap: () {
                        toggleButtonBiometric(context);
                      },
                      child: ToggleCustomWidget(
                        value: valueSelected,
                      )),
                ],
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  "Sử dụng vân tay hoặc FaceID để đăng nhập ứng dụng",
                  style: TextStyle(
                    fontSize: 16,
                    color: GlobalVariables.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
