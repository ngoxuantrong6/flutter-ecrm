import 'package:amazon_clone_tutorial/common/widgets/custom_button.dart';
import 'package:amazon_clone_tutorial/common/widgets/custom_textfield.dart';
import 'package:amazon_clone_tutorial/common/widgets/custom_textfield_label.dart';
import 'package:amazon_clone_tutorial/constants/global_variables.dart';
import 'package:amazon_clone_tutorial/features/account/services/account_services.dart';
import 'package:amazon_clone_tutorial/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String routeName = '/change-password';
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();
  final AccountServices accountServices = AccountServices();
  final _addProductFormKey = GlobalKey<FormState>();
  bool isNotSame = false;

  // @override
  // void initState() {
  //   final user = Provider.of<UserProvider>(context, listen: false).user;
  //   oldPasswordController.text = user.name;
  //   newPasswordController.text = user.email;
  //   confirmNewPasswordController.text = user.address;
  //   super.initState();
  // }

  @override
  void dispose() {
    super.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
  }

  void changePassword() {
    if (_addProductFormKey.currentState!.validate()) {
      accountServices.changePassword(
        context: context,
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: GlobalVariables.appBarGradient,
              ),
            ),
            title: const Text(
              'Cập nhật mật khẩu',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.transparent,
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _addProductFormKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: oldPasswordController,
                    hintText: 'Mật khẩu cũ',
                    passwordField: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: newPasswordController,
                    hintText: 'Mật khẩu mới',
                    passwordField: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: confirmNewPasswordController,
                    hintText: 'Xác nhận mật khẩu mới',
                    passwordField: true,
                    isNotSamePass: isNotSame,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onTextChanged: (value) {
                      if (newPasswordController.text !=
                          confirmNewPasswordController.text) {
                        setState(() => isNotSame = true);
                      } else {
                        setState(() => isNotSame = false);
                      }
                    },
                  ),
                  const SizedBox(height: 50),
                  CustomButton(
                    text: 'Cập nhật',
                    onTap: changePassword,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
