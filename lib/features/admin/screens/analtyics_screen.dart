import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/admin/models/sales.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter_ecrm/features/admin/services/branch_services.dart';
import 'package:flutter_ecrm/features/admin/widgets/category_products_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/fetch_branch_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final BranchServices branchServices = BranchServices();
  final AdminServices adminServices = AdminServices();
  User? user;
  int? totalSales;
  List<Sales>? earnings;
  List<User>? branches;

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    if (user?.type == "admin") {
      fetchAllBranches();
    }
    getEarnings(branchId: "");
  }

  fetchAllBranches() async {
    branches = await adminServices.fetchAllBranches(context);
    GlobalVariables.branches = branches ?? [];
    Provider.of<FetchBranchProvider>(context, listen: false).setListBranch();
    setState(() {});
  }

  getEarnings({required String branchId}) async {
    earnings = null;
    totalSales = null;
    var earningData = user?.type == "admin"
        ? await adminServices.getEarnings(context, branchId)
        : await branchServices.getEarnings(context);
    totalSales = earningData['totalEarnings'];
    earnings = earningData['sales'];
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final fetchBranchProvider = context.watch<FetchBranchProvider>();
    return earnings == null || totalSales == null
        ? const Loader()
        : SingleChildScrollView(
            child: Column(
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
                        items: fetchBranchProvider.listBranch.map((User item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item.name),
                          );
                        }).toList(),
                        onChanged: (User? newVal) {
                          fetchBranchProvider.setBranch(newVal!);
                          getEarnings(branchId: fetchBranchProvider.branch.id);
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Text(
                  'Tổng thu nhập: ${formatPriceInt(totalSales!)} đ',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 250,
                  child: CategoryProductsChart(seriesList: [
                    charts.Series(
                      id: 'Sales',
                      data: earnings!,
                      domainFn: (Sales sales, _) => sales.label,
                      measureFn: (Sales sales, _) => sales.earning,
                    ),
                  ]),
                )
              ],
            ),
          );
  }
}
