import 'package:flutter/material.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.hexagonDots(
        color: GlobalVariables.secondaryColor,
        size: 50,
      ),
    );
  }
}
