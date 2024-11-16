import 'package:flutter/material.dart';
import 'package:flutter_ecrm/Model/ChatModel.dart';
import 'package:flutter_ecrm/Screens/IndividualPage.dart';
import 'package:flutter_ecrm/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({Key? key, required this.chatModel}) : super(key: key);
  final ChatModel chatModel;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context, listen: false).user;
    User receiver = chatModel.members.firstWhere(
      (member) => member.id != user.id,
    );
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          IndividualPage.routeName,
          arguments: IndividualPageArguments(receiver: receiver),
        );
      },
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: Image.asset(
                "assets/images/img_loading_avatar.png",
                // height: 36,
                // width: 36,
              ),
              backgroundColor: Colors.blueGrey,
            ),
            title: Text(
              receiver.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.done_all),
                SizedBox(
                  width: 3,
                ),
                Flexible(
                  child: Text(
                    chatModel.lastMessage?.message ?? "",
                    style: TextStyle(
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            // trailing: Text(
            //   DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(
            //       chatModel.messages[0].createdAt)),
            // ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 80),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
