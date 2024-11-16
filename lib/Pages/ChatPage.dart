import 'package:flutter/material.dart';
import 'package:flutter_ecrm/CustomUI/CustomCard.dart';
import 'package:flutter_ecrm/Model/ChatModel.dart';
import 'package:flutter_ecrm/Model/MessageModel.dart';
import 'package:flutter_ecrm/Pages/ChatPageServices.dart';
import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/widgets/below_app_bar.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_ecrm/Screens/SelectContact.dart';

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
          // ..add(ChatModel(
          //     id: "672499ba502334975b1bd621",
          //     members: [
          //       User(
          //         id: "64e33407471caeb00e89ca70",
          //         name: "Trọng Ngô",
          //         email: "trongbanhang@gmail.com",
          //         password: "",
          //         address: "141 Chiến Thắng, Tân Triều, Thanh Trì, Hà Nội",
          //         type: "user",
          //         token: "",
          //         cart: [],
          //       ),
          //       User(
          //         id: "6708a30a7ad8a99e8a76351c",
          //         name: "Chi nhánh Đà Nẵng",
          //         email: "branchdanang@gmail.com",
          //         password: "",
          //         address:
          //             "Số 7 Trường Sa, Phường Hoà Hải, Quận Ngũ Hành Sơn, Thành phố Đà Nẵng, Việt Nam",
          //         type: "branch",
          //         token: "",
          //         cart: [],
          //       ),
          //     ],
          //     messages: [],
          //     lastMessage: MessageModel(
          //       id: "",
          //       senderId: "",
          //       receiverId: "",
          //       message: "",
          //       createdAt: 0,
          //     ),
          //     createdAt: 0));
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
                      child: const Text(
                        "ECRM PRO",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
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
