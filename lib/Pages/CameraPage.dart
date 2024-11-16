import 'package:flutter/material.dart';
import 'package:flutter_ecrm/Model/ChatModel.dart';
import 'package:flutter_ecrm/Screens/CameraScreen.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/individual_page_provider.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({
    Key? key,
    required this.sender,
    required this.receiver,
    required this.provider,
  }) : super(key: key);
  final User sender;
  final User receiver;
  final IndividualPageProvider provider;

  @override
  Widget build(BuildContext context) {
    return CameraScreen(
      sender: sender,
      receiver: receiver,
      provider: provider,
    );
  }
}
