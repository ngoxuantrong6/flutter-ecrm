import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/common/widgets/popup_notification_custom.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/helper/encryption_helper.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

enum Auth {
  // chức năng đăng nhập
  signin,
  signup,
}

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Auth _auth = Auth.signup; // mặc định hiển thị màn hình đăng ký
  final _signUpFormKey = GlobalKey<
      FormState>(); // khóa được dùng để xác nhận trạng thái của các form đang nhập
  final _signInFormKey = GlobalKey<
      FormState>(); // khóa được dùng để xác nhận trạng thái của các form đang nhập
  final AuthService authService = AuthService();
  final TextEditingController _emailController =
      TextEditingController(); // Các controller liên quan tới trường nhập dữ liệu
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  List<String> hashedPassword = []; // Tạo mảng chứa giá trị mật khẩu đã mã hóa
  String? userName = "";
  String? email = "";
  final LocalAuthentication auth =
      LocalAuthentication(); // tạo biến xác thực người dùng sẽ yêu cầu xác thực sinh trắc học
  bool isFingerPrint =
      false; // Kiểm tra xem người dùng đã chọn đăng nhập bằng vân tay hay chưa

  @override
  void initState() {
    //lấy thông tin tài khoản đã lưu
    getUserName(); // gọi username
    super.initState();
  }

  void getUserName() async {
    await EncryptedSharedPreferences.initialize(key);
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences
        .getInstance(); // lấy data của encry.. để truy cập dữ liệu đã lưu
    userName = prefs.getString('userName');
    email = prefs.getString('email');
    if (userName != null && userName != "") {
      // kiểm tra xem người dùng đã có thông tin username hay chưa
      _emailController.text = email ?? "";
      GlobalVariables.checkUserExist = true; // nếu có thì điền email vào
    } else {
      GlobalVariables.checkUserExist = false;
    }
  }

  void loginAnotherAccount() {
    // khi người dùng muốn login bằng tài khoản khác
    setState(() {
      // cập nhật trang thái của widget
      GlobalVariables.checkUserExist =
          false; // đặt Lại trạng thái globalVariables bằng không
      _emailController.text = ""; // xóa nội dung trường email trong form
    });
  }

  @override
  // phương thức được gọi khi Widget không còn tồn tại hoặc không được sử udnjg nữa, giải phóng bộ tró của các contronller
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  void signUpUser() {
    // khi người dùng click vào nút đăng ký , gửi thông tin đến client
    authService.signUpUser(
      context: context,
      email: _emailController.text, // Truyền giá trị trường email từ controller
      password: _passwordController
          .text, //Truyền giá trị trường mật khẩu từ controller
      name: _nameController.text, //Truyền giá trị trường name từ controller
    );
  }

  void signInUser() async {
    if (_passwordController.text.isNotEmpty) {
      // kiểm tra xem người dùng nhập pass hay không
      //notEmty không rỗng
      hashedPassword = EncryptionHelper.hashPassword(_passwordController.text
          .trim()); // mã hóa mật khẩu người dùng bằng phương thức hashPassWord từ lớp EncrytionHelper
    }
    print("hash password${hashedPassword[0]}");
    print("hash password${hashedPassword[1]}");

    authService.signInUser(
      // gọi phương thức signInUser đến authenService để thực hiện đăng nhập
      context: context,
      email: _emailController.text,
      hashedPassword0: isFingerPrint
          ? ""
          : hashedPassword[
              0], // mật khẩu đã hóa nếu đăng nhập bằng vân tay sẽ bỏ qua
      encryption_key: isFingerPrint ? "" : hashedPassword[1], // mã hóa khóa
      isFingerPrint:
          isFingerPrint, // kiểm tra xem người dùng có đăng nhập bằng vân tay không
      hashedPasswordArg:
          hashedPassword, // mảng chưa các giá trị liên quan tới mật khẩu đã mã hóa
    );
  }

  void loginFinger(BuildContext context) async {
    // xử lý đăng nhập qua vân tay ,
    if (_emailController.text.trim().isEmpty) {
      // kiểm tra xem người email có đang bị bỏ trống hay không , nếu người dùng nhập thông tin đăng nhập và dừng lại
      PopupNotificationCustom.showMessgae(
        context: context,
        title: 'THÔNG BÁO',
        message: 'Vui lòng nhập thông tin đăng nhập',
        buttonTitleLeft: "Đồng ý",
        hiddenButtonRight: true,
      );
      return;
    }
    await EncryptedSharedPreferences.initialize(
        key); // khởi tạo và cài đặt vân tay từ EncryptedSharedPreferences
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    bool biometric = prefs.getBoolean('biometric') ??
        false; // kiểm tra xem người dùng đã kích hoạt chức năng vân tay hay chưa
    // trước khi kiểm tra phải xem đã đk vân tay chưa
    if (biometric == true) {
      funcFingerPrint(
          context); // nếu chức năng vân tay đã được kích hoạt, gọi hàm funcFingerPrint
    } else {
      PopupNotificationCustom.showMessgae(
        context: context,
        title: 'THÔNG BÁO',
        message:
            'Quý khách vui lòng đăng nhập ứng dụng Shop Be và sử dụng chức năng Cài đặt đăng nhập Face ID/ vân tay để kích hoạt tính năng này!',
        buttonTitleLeft: "Đồng ý",
        hiddenButtonRight: true,
      );
    }
  }

  Future<void> funcFingerPrint(BuildContext context) async {
    // xử lý việc
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (canCheckBiometrics) {
      // check xem thiết bị có thể sinh trắc học hay không
      bool isAuthorized = false;
      try {
        isAuthorized = await LocalAuthentication().authenticate(
            //yêu cầu người dùng xác thực vân tya hoặc Face ID
            localizedReason: "Vui lòng xác thực để đăng nhập",
            authMessages: <AuthMessages>[
              const AndroidAuthMessages(
                cancelButton: 'Hủy',
                goToSettingsButton: 'Cài đặt',
                goToSettingsDescription:
                    'Vui lòng thiết lập Touch ID/Face ID của Quý khách',
                signInTitle: 'Xác minh Touch ID/Face ID của Quý khách',
              ),
              const IOSAuthMessages(
                cancelButton: 'Hủy',
                goToSettingsButton: 'Cài đặt',
                goToSettingsDescription:
                    'Vui lòng thiết lập Touch ID/Face ID của Quý khách',
                lockOut: 'Vui lòng kích hoạt Touch ID/Face ID của Quý khách',
              )
            ],
            options: const AuthenticationOptions(
              useErrorDialogs: true,
              stickyAuth: true,
              biometricOnly: true,
            ));
      } on PlatformException catch (e) {
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
        auth.stopAuthentication();
      }
      if (isAuthorized) {
        isFingerPrint = true;
        signInUser();
      }
    } else {
      PopupNotificationCustom.showMessgae(
        context: context,
        title: 'THÔNG BÁO',
        message:
            'Thiết bị chưa cài đặt dấu vân tay/FaceID. Quý khách vui lòng cài đặt dấu vân tay hoặc FaceID trên thiết bị trước',
        buttonTitleLeft: "Đồng ý",
        hiddenButtonRight: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.greyBackgroundCOlor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào bạn',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ListTile(
                  tileColor: _auth == Auth.signup
                      ? GlobalVariables.backgroundColor
                      : GlobalVariables.greyBackgroundCOlor,
                  title: const Text(
                    'Tạo tài khoản',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Radio(
                    activeColor: GlobalVariables.secondaryColor,
                    value: Auth.signup,
                    groupValue: _auth,
                    onChanged: (Auth? val) {
                      setState(() {
                        _auth = val!;
                      });
                    },
                  ),
                ),
                if (_auth == Auth.signup)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: GlobalVariables.backgroundColor,
                    child: Form(
                      key: _signUpFormKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Tên',
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: 'Mật khẩu',
                            passwordField: true,
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: 'Đăng Ký',
                            onTap: () {
                              if (_signUpFormKey.currentState!.validate()) {
                                signUpUser();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ListTile(
                  tileColor: _auth == Auth.signin
                      ? GlobalVariables.backgroundColor
                      : GlobalVariables.greyBackgroundCOlor,
                  title: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Radio(
                    activeColor: GlobalVariables.secondaryColor,
                    value: Auth.signin,
                    groupValue: _auth,
                    onChanged: (Auth? val) {
                      setState(() {
                        _auth = val!;
                      });
                    },
                  ),
                ),
                if (_auth == Auth.signin)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: GlobalVariables.backgroundColor,
                    child: Form(
                      key: _signInFormKey,
                      child: Column(
                        children: [
                          if (GlobalVariables.checkUserExist)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Xin chào, $userName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (!GlobalVariables.checkUserExist)
                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          const SizedBox(height: 10),
                          if (GlobalVariables.checkUserExist)
                            const SizedBox(height: 20),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: 'Mật khẩu',
                            passwordField: true,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Đăng Nhập',
                                  onTap: () {
                                    if (_signInFormKey.currentState!
                                        .validate()) {
                                      signInUser();
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: InkWell(
                                  onTap: () => loginFinger(context),
                                  child: SvgPicture.asset(
                                    'assets/icons/fingerprint.svg',
                                    height: 40,
                                    width: 40,
                                    color: GlobalVariables.secondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (GlobalVariables.checkUserExist)
                            const SizedBox(height: 30),
                          if (GlobalVariables.checkUserExist)
                            InkWell(
                              onTap: () => loginAnotherAccount(),
                              child: const Text(
                                'Đăng nhập bằng tài khoản khác',
                                // style: bodyTextApiSandboxRegular.copyWith(
                                //   color: colorPrimary,
                                // ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
