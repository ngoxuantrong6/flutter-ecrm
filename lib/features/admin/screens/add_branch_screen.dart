import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/admin/screens/manage_branch_screen.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter/material.dart';

class AddBranchScreen extends StatefulWidget {
  static const String routeName = '/add-branch';
  const AddBranchScreen({Key? key, required this.addBranchArguments})
      : super(key: key);
  final AddBranchArguments addBranchArguments;

  @override
  State<AddBranchScreen> createState() => _AddBranchScreenState();
}

class _AddBranchScreenState extends State<AddBranchScreen> {
  final AdminServices adminServices = AdminServices();
  final _addBranchFormKey = GlobalKey<FormState>();

  void addBranch() {
    if (_addBranchFormKey.currentState!.validate()) {
      adminServices.addBranch(
        context: context,
        branchName: widget.addBranchArguments.branchNameController.text,
        address: widget.addBranchArguments.addressController.text,
        email: widget.addBranchArguments.emailController.text,
        password: widget.addBranchArguments.passwordController.text,
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
            'Thêm chi nhánh',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _addBranchFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CustomTextField(
                  controller: widget.addBranchArguments.branchNameController,
                  hintText: 'Tên chi nhánh',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: widget.addBranchArguments.addressController,
                  hintText: 'Địa chỉ',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: widget.addBranchArguments.emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: widget.addBranchArguments.passwordController,
                  hintText: 'Mật khẩu',
                  passwordField: true,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Thêm',
                  onTap: addBranch,
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
