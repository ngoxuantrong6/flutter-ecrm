import 'package:amazon_clone_tutorial/common/widgets/popup_notification_custom.dart';
import 'package:amazon_clone_tutorial/constants/global_variables.dart';
import 'package:amazon_clone_tutorial/features/account/services/account_services.dart';
import 'package:amazon_clone_tutorial/features/admin/screens/analtyics_screen.dart';
import 'package:amazon_clone_tutorial/features/admin/screens/orders_screen.dart';
import 'package:amazon_clone_tutorial/features/admin/screens/posts_screen.dart';
import 'package:flutter/material.dart';

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

  List<Widget> pages = [
    const PostsScreen(),
    const AnalyticsScreen(),
    const OrdersScreen(),
  ];

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
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
            IconButton(
              onPressed: () {
                PopupNotificationCustom.showMessgae(
                  context: context,
                  title: 'ĐĂNG XUẤT',
                  message: 'Bạn có thực sự muốn thoát phiên đăng nhập này?',
                  pressButtonLeft: () => AccountServices().logOut(context),
                );
              },
              icon: const Icon(Icons.logout),
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
          // ANALYTICS
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
                    color: _page == 2
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
        ],
      ),
    );
  }
}
