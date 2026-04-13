import 'package:flutter_ecrm/Model/ChatModel.dart';
import 'package:flutter_ecrm/Model/MessageModel.dart';
import 'package:flutter_ecrm/features/chat/screens/ChatPage.dart';
import 'package:flutter_ecrm/features/chat/services/ChatPageServices.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/account/screens/account_screen.dart';
import 'package:flutter_ecrm/features/cart/screens/cart_screen.dart';
import 'package:flutter_ecrm/features/home/screens/home_screen.dart';
import 'package:flutter_ecrm/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_ecrm/helper/encryption_helper.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/individual_page_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text_provider.dart';

class BottomBar extends StatefulWidget {
  static const String routeName = '/actual-home';
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _page = 0;
  double bottomBarWidth = 42;
  double bottomBarBorderWidth = 5;
  final stt.SpeechToText speech = stt.SpeechToText();
  User? user;
  List<Widget> pages = [];

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  void initState() {
    checkRootJailbreak();
    user = Provider.of<UserProvider>(context, listen: false).user;
    GlobalVariables.speechProvider = SpeechToTextProvider(speech);
    initSpeechProvider();
    pages = [
      const HomeScreen(),
      ChatPage(),
      const AccountScreen(),
      const CartScreen(),
    ];
    super.initState();
  }

  Future<void> initSpeechProvider() async {
    await GlobalVariables.speechProvider.initialize();
  }

  Future<void> checkRootJailbreak() async {
    bool isJaiBreak = await deviceRootJailbreak(context);
    if (isJaiBreak) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userCartLen = context.watch<UserProvider>().user.cart.length;

    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        selectedItemColor: GlobalVariables.primaryColor,
        unselectedItemColor: GlobalVariables.unselectedNavBarColor,
        backgroundColor: GlobalVariables.backgroundColor,
        iconSize: 28,
        onTap: updatePage,
        items: [
          // HOME
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
          // CHAT
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
          // ACCOUNT
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
                Icons.person_outline_outlined,
              ),
            ),
            label: '',
          ),
          // CART
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
              child: badges.Badge(
                elevation: 0,
                badgeContent: Text(userCartLen.toString()),
                badgeColor: Colors.white,
                child: const Icon(
                  Icons.shopping_cart_outlined,
                ),
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
