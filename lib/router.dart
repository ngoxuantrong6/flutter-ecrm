import 'package:flutter_ecrm/Model/ChatModel.dart';
import 'package:flutter_ecrm/Screens/IndividualPage.dart';
import 'package:flutter_ecrm/common/widgets/bottom_bar.dart';
import 'package:flutter_ecrm/features/account/screens/change_password_screen.dart';
import 'package:flutter_ecrm/features/account/screens/my_orders_screen.dart';
import 'package:flutter_ecrm/features/account/screens/update_profile_screen.dart';
import 'package:flutter_ecrm/features/address/screens/address_buy_now_screen.dart';
import 'package:flutter_ecrm/features/address/screens/address_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/add_branch_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/add_product_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/admin_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/edit_branch_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/edit_product_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/manage_branch_screen.dart';
import 'package:flutter_ecrm/features/auth/screens/auth_screen.dart';
import 'package:flutter_ecrm/features/home/screens/category_deals_screen.dart';
import 'package:flutter_ecrm/features/home/screens/home_screen.dart';
import 'package:flutter_ecrm/features/order_details/screens/order_details.dart';
import 'package:flutter_ecrm/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_ecrm/features/search/screens/search_screen.dart';
import 'package:flutter_ecrm/models/order.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/individual_page_provider.dart';
import 'package:provider/provider.dart';

import 'features/admin/screens/posts_screen.dart';
import 'providers/fetch_branch_provider.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AuthScreen(),
      );

    case HomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const HomeScreen(),
      );
    case BottomBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BottomBar(),
      );
    // case AddProductScreen.routeName:
    //   var addProductArguments = routeSettings.arguments as AddProductArguments;
    //   return MaterialPageRoute(
    //     settings: routeSettings,
    //     builder: (_) =>
    //         AddProductScreen(addProductArguments: addProductArguments),
    //   );

    case AddProductScreen.routeName:
      var addProductArguments = routeSettings.arguments as AddProductArguments;
      return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<FetchBranchProvider>(
                create: (context) => FetchBranchProvider(),
                child:
                    AddProductScreen(addProductArguments: addProductArguments),
              ));

    case AddBranchScreen.routeName:
      var addBranchArguments = routeSettings.arguments as AddBranchArguments;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => AddBranchScreen(addBranchArguments: addBranchArguments),
      );

    // case CategoryDealsScreen.routeName:
    //   var category = routeSettings.arguments as String;
    //   return MaterialPageRoute(
    //     settings: routeSettings,
    //     builder: (_) => CategoryDealsScreen(
    //       category: category,
    //     ),
    //   );

    case CategoryDealsScreen.routeName:
      var category = routeSettings.arguments as String;
      return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<FetchBranchProvider>(
              create: (context) => FetchBranchProvider(),
              child: CategoryDealsScreen(category: category)));
    case SearchScreen.routeName:
      var searchQuery = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => SearchScreen(
          searchQuery: searchQuery,
        ),
      );
    case ProductDetailScreen.routeName:
      var productId = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => ProductDetailScreen(
          productId: productId,
        ),
      );
    case AddressScreen.routeName:
      var totalAmount = routeSettings.arguments as String;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => AddressScreen(
          totalAmount: totalAmount,
        ),
      );
    case OrderDetailScreen.routeName:
      var order = routeSettings.arguments as Order;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => OrderDetailScreen(
          order: order,
        ),
      );
    case AdminScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AdminScreen(),
      );
    case EditProductScreen.routeName:
      var product = routeSettings.arguments as Product;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => EditProductScreen(
          product: product,
        ),
      );
    case EditBranchScreen.routeName:
      var branch = routeSettings.arguments as User;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => EditBranchScreen(
          branch: branch,
        ),
      );
    case UpdateProfileScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const UpdateProfileScreen(),
      );
    case ChangePasswordScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ChangePasswordScreen(),
      );
    case MyOrdersScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const MyOrdersScreen(),
      );
    case AddressBuyNowScreen.routeName:
      var product = routeSettings.arguments as Product;
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => AddressBuyNowScreen(
          product: product,
        ),
      );

    case IndividualPage.routeName:
      var individualPageArguments =
          routeSettings.arguments as IndividualPageArguments;
      return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider<IndividualPageProvider>(
                create: (context) =>
                    IndividualPageProvider(context, individualPageArguments),
                child: IndividualPage(
                    individualPageArguments: individualPageArguments),
              ));
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Screen does not exist!'),
          ),
        ),
      );
  }
}
