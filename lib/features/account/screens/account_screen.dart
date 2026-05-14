import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/widgets/below_app_bar.dart';
import 'package:flutter_ecrm/features/account/widgets/orders.dart';
import 'package:flutter_ecrm/features/account/widgets/top_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

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
          title: Container(
            alignment: Alignment.topLeft,
            child: SvgPicture.asset(
              'assets/icons/logo_app.svg',
              height: 45,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            BelowAppBar(),
            SizedBox(height: 10),
            TopButtons(),
            SizedBox(height: 20),
            Orders(),
          ],
        ),
      ),
    );
  }
}
