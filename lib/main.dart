import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter_ecrm/common/widgets/bottom_bar.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/account/services/account_services.dart';
import 'package:flutter_ecrm/features/admin/screens/admin_screen.dart';
import 'package:flutter_ecrm/features/auth/screens/auth_screen.dart';
import 'package:flutter_ecrm/features/auth/services/auth_service.dart';
import 'package:flutter_ecrm/features/splash/screens/splash_screen.dart';
import 'package:flutter_ecrm/helper/encryption_helper.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/add_product_provider.dart';
import 'package:flutter_ecrm/providers/fetch_branch_provider.dart';
import 'package:flutter_ecrm/providers/individual_page_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter_ecrm/router.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_context/one_context.dart';

List<CameraDescription>? cameras;

void main() async {
  // Đảm bảo rằng WidgetsFlutterBinding đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Lấy danh sách các camera có sẵn
  cameras = await availableCameras();

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
    // ChangeNotifierProvider(
    //   create: (context) => IndividualPageProvider(context),
    // ),
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
  Timer _timer = Timer.periodic(Duration.zero, (_) {});
  Key uniqueKey = new UniqueKey();

  @override
  void initState() {
    super.initState();
    checkLogin();
    authService.getUserData(context);
  }

  Future<void> checkLogin() async {
    await EncryptedSharedPreferences.initialize(key);
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
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
      publicKey: "",
      privateKey: "",
    );
    // if (token == null || token == '') {
    prefs.setString('x-auth-token', '');
    OneContext.instance.navigator.pushNamedAndRemoveUntil(
      AuthScreen.routeName,
      (route) => false,
    );
    // } else {
    //   if (userString != null || userString != '') {
    //     user = User.fromJson(jsonDecode(userString!));
    //     var userProvider = Provider.of<UserProvider>(context, listen: false);
    //     userProvider.setUser(jsonDecode(userString));
    //   }
    //   if (user.type == 'user') {
    //     OneContext.instance.navigator.pushNamedAndRemoveUntil(
    //       BottomBar.routeName,
    //       (route) => false,
    //     );
    //   } else {
    // OneContext.instance.navigator.pushNamedAndRemoveUntil(
    //   AdminScreen.routeName,
    //   (route) => false,
    // );
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    void _initializeTimer(BuildContext context) {
      print("start time logout " + TIME_TO_LOGOUT.toString());
      _timer = Timer.periodic(const Duration(milliseconds: TIME_TO_LOGOUT),
          (Timer timer) {
        OneContext.instance.navigator.pushNamedAndRemoveUntil(
          AuthScreen.routeName,
          (route) => false,
        );
      });
    }

    void _handleUserInteraction(BuildContext context) {
      print("user using app");
      _timer.cancel();
      _initializeTimer(context);
    }

    return Listener(
      onPointerDown: (_) {
        _handleUserInteraction(context);
      },
      key: uniqueKey,
      child: MaterialApp(
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
      ),
    );
  }
}
