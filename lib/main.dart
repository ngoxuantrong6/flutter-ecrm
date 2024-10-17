import 'dart:convert';

import 'package:flutter_ecrm/common/widgets/bottom_bar.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/admin/screens/admin_screen.dart';
import 'package:flutter_ecrm/features/auth/screens/auth_screen.dart';
import 'package:flutter_ecrm/features/auth/services/auth_service.dart';
import 'package:flutter_ecrm/features/splash/screens/splash_screen.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/add_product_provider.dart';
import 'package:flutter_ecrm/providers/fetch_branch_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter_ecrm/router.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_context/one_context.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => AddProductProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => FetchBranchProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => GlobalVariables.speechProvider,
    ),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    checkLogin();
    authService.getUserData(context);
  }

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-auth-token');
    String? userString = prefs.getString('user');
    User? user = User(
      id: "",
      name: "",
      email: "",
      password: "",
      address: "",
      type: "",
      token: "",
      cart: [],
    );
    if (token == null || token == '') {
      prefs.setString('x-auth-token', '');
      OneContext.instance.navigator.pushNamedAndRemoveUntil(
        AuthScreen.routeName,
        (route) => false,
      );
    } else {
      if (userString != null || userString != '') {
        user = User.fromJson(jsonDecode(userString!));
        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(jsonDecode(userString));
      }
      if (user.type == 'user') {
        OneContext.instance.navigator.pushNamedAndRemoveUntil(
          BottomBar.routeName,
          (route) => false,
        );
      } else {
        OneContext.instance.navigator.pushNamedAndRemoveUntil(
          AdminScreen.routeName,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eCRM Pro',
      theme: ThemeData(
        scaffoldBackgroundColor: GlobalVariables.backgroundColor,
        colorScheme: const ColorScheme.light(
          primary: GlobalVariables.secondaryColor,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        useMaterial3: true, // can remove this line
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      navigatorKey: OneContext().navigator.key,
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: const SplashScreen(),
    );
  }
}
