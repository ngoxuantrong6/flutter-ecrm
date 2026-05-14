import 'package:flutter/material.dart';
import 'package:flutter_ecrm/CustomUI/CustomCard.dart';
import 'package:flutter_ecrm/Model/ChatModel.dart';
import 'package:flutter_ecrm/Model/MessageModel.dart';
import 'package:flutter_ecrm/features/chat/services/ChatPageServices.dart';
import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/widgets/below_app_bar.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_ecrm/features/SelectContact.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatPageServices chatPageServices = ChatPageServices();
  List<ChatModel> conversations = [];
  User? user;

  @override
  void initState() {
    user = Provider.of<UserProvider>(context, listen: false).user;
    if (user?.type == "branch") {
      chatPageServices.getConversations(context: context).then((value) {
        setState(() {
          conversations = value;
        });
      });
    } else {
      chatPageServices.getConversations(context: context).then((value) {
        setState(() {
          conversations = value;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: user?.type == "branch"
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: AppBar(
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: GlobalVariables.appBarGradient,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: SvgPicture.asset(
                        'assets/icons/logo_app.svg',
                        height: 45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Column(
        children: [
          const BelowAppBar(),
          const SizedBox(height: 10),
          conversations.isEmpty
              ? const Loader()
              : Expanded(
                  child: ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (contex, index) {
                      return CustomCard(
                        chatModel: conversations[index],
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
