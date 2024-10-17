import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/models/user.dart';

class EditBranchScreen extends StatefulWidget {
  static const String routeName = '/edit-branch';
  const EditBranchScreen({Key? key, required this.branch}) : super(key: key);
  final User branch;

  @override
  State<EditBranchScreen> createState() => _EditBranchScreenState();
}

class _EditBranchScreenState extends State<EditBranchScreen> {
  final AdminServices adminServices = AdminServices();
  final _editBranchFormKey = GlobalKey<FormState>();
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    branchNameController.text = widget.branch.name;
    addressController.text = widget.branch.address;
    emailController.text = widget.branch.email;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    branchNameController.dispose();
    addressController.dispose();
    emailController.dispose();
  }

  void editBranch() {
    if (_editBranchFormKey.currentState!.validate()) {
      adminServices.editBranch(
        context: context,
        branchName: branchNameController.text,
        address: addressController.text,
        email: emailController.text,
        branchId: widget.branch.id,
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
            'Sửa chi nhánh',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _editBranchFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CustomTextField(
                  controller: branchNameController,
                  hintText: 'Tên chi nhánh',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: addressController,
                  hintText: 'Địa chỉ',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Sửa',
                  onTap: editBranch,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
