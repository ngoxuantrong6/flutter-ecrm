import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield_label.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/services/account_services.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const String routeName = '/update-profile';
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final AccountServices accountServices = AccountServices();
  final _addProductFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    userNameController.text = user.name;
    emailController.text = user.email;
    addressController.text = user.address;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    userNameController.dispose();
    emailController.dispose();
    addressController.dispose();
  }

  void updateProfile() {
    if (_addProductFormKey.currentState!.validate()) {
      accountServices.updateProfile(
        context: context,
        userName: userNameController.text,
        address: addressController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Thông tin cá nhân',
            style: TextStyle(
              color: Colors.black,
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
                  controller: userNameController,
                  hintText: 'Tên',
                ),
                const SizedBox(height: 10),
                CustomTextFieldLabel(email: emailController.text),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: addressController,
                  hintText: 'Địa chỉ',
                ),
                const SizedBox(height: 50),
                CustomButton(
                  text: 'Cập nhật',
                  onTap: updateProfile,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
