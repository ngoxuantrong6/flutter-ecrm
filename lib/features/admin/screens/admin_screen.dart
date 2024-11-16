import 'package:flutter_ecrm/Model/ChatModel.dart';
import 'package:flutter_ecrm/Pages/ChatPage.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/admin/screens/analtyics_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/manage_branch_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/orders_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/posts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/features/admin/screens/setting_screen.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/fetch_branch_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  static const String routeName = '/admin';
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _page = 0;
  double bottomBarWidth = 42;
  double bottomBarBorderWidth = 5;
  User? user;
  List<User>? branches;
  AdminServices adminServices = AdminServices();

  List<Widget> pages = [
    ChangeNotifierProvider<FetchBranchProvider>(
      create: (context) => FetchBranchProvider(),
      child: const PostsScreen(),
    ),
    ChangeNotifierProvider<FetchBranchProvider>(
      create: (context) => FetchBranchProvider(),
      child: const AnalyticsScreen(),
    ),
    ChangeNotifierProvider<FetchBranchProvider>(
      create: (context) => FetchBranchProvider(),
      child: const OrdersScreen(),
    ),
    const SettingScreen(),
  ];

  @override
  void initState() {
    user = Provider.of<UserProvider>(context, listen: false).user;
    if (user?.type == "admin") {
      pages.insert(1, const ManageBranchScreen());
      fetchAllBranches();
    } else {
      pages.insert(1, ChatPage());
    }
    super.initState();
  }

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  fetchAllBranches() async {
    branches = await adminServices.fetchAllBranches(context);
    GlobalVariables.branches = branches ?? [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          toolbarHeight: 56,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Container(
            alignment: Alignment.topLeft,
            // child: Image.asset(
            //   'assets/images/amazon_in.png',
            //   width: 120,
            //   height: 45,
            //   color: Colors.black,
            // ),
            child: const Text(
              "ECRM PRO",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            // IconButton(
            //   onPressed: () {
            //     PopupNotificationCustom.showMessgae(
            //       context: context,
            //       title: 'ĐĂNG XUẤT',
            //       message: 'Bạn có thực sự muốn thoát phiên đăng nhập này?',
            //       pressButtonLeft: () => AccountServices().logOut(context),
            //     );
            //   },
            //   icon: const Icon(Icons.logout),
            // ),
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(
                user?.type == "admin" ? "Admin" : "Chi nhánh",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        selectedItemColor: GlobalVariables.primaryColor,
        unselectedItemColor: GlobalVariables.unselectedNavBarColor,
        backgroundColor: GlobalVariables.backgroundColor,
        iconSize: 28,
        onTap: updatePage,
        items: [
          // POSTS
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 0
                        ? GlobalVariables.primaryColor
                        : GlobalVariables.backgroundColor,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(
                Icons.home_outlined,
              ),
            ),
            label: '',
          ),
          // MANAGE BRANCH
          if (user?.type == "admin") ...[
            BottomNavigationBarItem(
              icon: Container(
                width: bottomBarWidth,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: _page == 1
                          ? GlobalVariables.primaryColor
                          : GlobalVariables.backgroundColor,
                      width: bottomBarBorderWidth,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.add_business_outlined,
                ),
              ),
              label: '',
            ),
          ] else ...[
            BottomNavigationBarItem(
              icon: Container(
                width: bottomBarWidth,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: _page == 1
                          ? GlobalVariables.primaryColor
                          : GlobalVariables.backgroundColor,
                      width: bottomBarBorderWidth,
                    ),
                  ),
                ),
                child: const Icon(
                  Icons.chat_outlined,
                ),
              ),
              label: '',
            ),
          ],
          // ANALYTICS
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 2
                        ? GlobalVariables.primaryColor
                        : GlobalVariables.backgroundColor,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(
                Icons.analytics_outlined,
              ),
            ),
            label: '',
          ),
          // ORDERS
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 3
                        ? GlobalVariables.primaryColor
                        : GlobalVariables.backgroundColor,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(
                Icons.all_inbox_outlined,
              ),
            ),
            label: '',
          ),
          // SETTING
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 4
                        ? GlobalVariables.primaryColor
                        : GlobalVariables.backgroundColor,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(
                Icons.person_outline_outlined,
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
