import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/widgets/single_product.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter_ecrm/features/admin/services/branch_services.dart';
import 'package:flutter_ecrm/features/order_details/screens/order_details.dart';
import 'package:flutter_ecrm/models/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/fetch_branch_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order>? orders;
  final BranchServices branchServices = BranchServices();
  final AdminServices adminServices = AdminServices();
  User? user;
  List<User>? branches;

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    if (user?.type == "admin") {
      fetchAllBranches();
    }
    fetchOrders(branchId: "");
  }

  fetchAllBranches() async {
    branches = await adminServices.fetchAllBranches(context);
    GlobalVariables.branches = branches ?? [];
    Provider.of<FetchBranchProvider>(context, listen: false).setListBranch();
    setState(() {});
  }

  void fetchOrders({required String branchId}) async {
    orders = null;
    orders = user?.type == "admin"
        ? await adminServices.fetchAllOrders(context, branchId)
        : await branchServices.fetchAllOrders(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fetchBranchProvider = context.watch<FetchBranchProvider>();
    return orders == null
        ? const Loader()
        : OrientationBuilder(
            builder: (context, orientation) {
              return Column(
                children: [
                  if (user?.type == "admin") ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 30,
                        child: DropdownButton(
                          value: fetchBranchProvider.branch,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items:
                              fetchBranchProvider.listBranch.map((User item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(item.name),
                            );
                          }).toList(),
                          onChanged: (User? newVal) {
                            fetchBranchProvider.setBranch(newVal!);
                            fetchOrders(
                                branchId: fetchBranchProvider.branch.id);
                          },
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: orders!.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        final orderData = orders![index];
                        return ZoomTapAnimation(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              OrderDetailScreen.routeName,
                              arguments: orderData,
                            );
                          },
                          child: SizedBox(
                            height: 140,
                            child: SingleProduct(
                              image: orderData.products[0].images[0],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
  }
}
