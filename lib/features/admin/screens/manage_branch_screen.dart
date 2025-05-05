import 'package:flutter_ecrm/common/widgets/popup_notification_custom.dart';
import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/widgets/single_product.dart';
import 'package:flutter_ecrm/features/admin/screens/add_branch_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/add_product_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/edit_branch_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/edit_product_screen.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter_ecrm/features/admin/services/branch_services.dart';
import 'package:flutter_ecrm/features/admin/widgets/branch_item.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/add_product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AddBranchArguments {
  final TextEditingController branchNameController;
  final TextEditingController addressController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  AddBranchArguments({
    required this.branchNameController,
    required this.addressController,
    required this.emailController,
    required this.passwordController,
  });
}

class ManageBranchScreen extends StatefulWidget {
  const ManageBranchScreen({Key? key}) : super(key: key);

  @override
  State<ManageBranchScreen> createState() => _ManageBranchScreenState();
}

class _ManageBranchScreenState extends State<ManageBranchScreen> {
  List<User>? branches;
  final AdminServices adminServices = AdminServices();
  User? user;
  bool isLoading = false; // Thêm trạng thái tải

  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    fetchAllBranches();
  }

  Future<void> fetchAllBranches() async {
    setState(() {
      isLoading = true;
    });
    try {
      branches = await adminServices.fetchAllBranches(context);
      GlobalVariables.branches = branches ?? [];
    } catch (e) {
      debugPrint('Error fetching branches: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi nhánh: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> deleteBranch(User branch, int index) async {
    try {
      await adminServices.deleteBranch(
        context: context,
        branch: branch,
        onSuccess: () {
          if (mounted) {
            branches!.removeAt(index);
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Xóa chi nhánh thành công!')),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Error deleting branch: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xóa chi nhánh: $e')),
      );
    }
  }

  void navigateToAddBranch() {
    Navigator.pushNamed(
      context,
      AddBranchScreen.routeName,
      arguments: AddBranchArguments(
        branchNameController: branchNameController,
        addressController: addressController,
        emailController: emailController,
        passwordController: passwordController,
      ),
    ).then((value) {
      if (value != null && mounted) {
        fetchAllBranches();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loader()
        : branches == null
            ? const Center(child: Text('Không có chi nhánh nào'))
            : Scaffold(
                body: ListView.builder(
                  itemCount: branches!.length,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          EditBranchScreen.routeName,
                          arguments: branches![index],
                        ).then((value) {
                          if (value != null && mounted) {
                            fetchAllBranches();
                          }
                        });
                      },
                      child: BranchItem(
                        index: index,
                        branches: branches!,
                        onDeleteBranch: () =>
                            deleteBranch(branches![index], index),
                      ),
                    );
                  },
                ),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: navigateToAddBranch,
                  tooltip: 'Thêm chi nhánh',
                  backgroundColor: GlobalVariables.primaryColor,
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
              );
  }
}
