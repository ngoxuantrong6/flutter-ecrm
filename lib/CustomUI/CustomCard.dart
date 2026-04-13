import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/Model/ChatModel.dart';
import 'package:flutter_ecrm/features/chat/screens/IndividualPage.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_ecrm/helper/encryption_helper.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomCard extends StatefulWidget {
  const CustomCard({Key? key, required this.chatModel}) : super(key: key);
  final ChatModel chatModel;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  late User user;
  List<String>? hashedPassword = [];
  String decrypted_private_key = "";
  @override
  void initState() {
    user = Provider.of<UserProvider>(context, listen: false).user;
    getHashedPassword().then((value) {
      setState(() {
        decrypted_private_key = EncryptionHelper.decryptPrivateKey(
          value![1],
          user.privateKey,
        );
      });
    });
    super.initState();
  }

  Future<List<String>?> getHashedPassword() async {
    await EncryptedSharedPreferences.initialize(key);
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    hashedPassword = prefs.getStringList('hashedPassword');
    return hashedPassword;
  }

  @override
  Widget build(BuildContext context) {
    User receiver = widget.chatModel.members.firstWhere(
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
                    // chatModel.lastMessage?.messageEncryptForMe ?? "",
                    decrypted_private_key == ""
                        ? ""
                        : (widget.chatModel.lastMessage?.senderId == user.id)
                            ? decrypt(
                                widget.chatModel.lastMessage
                                        ?.messageEncryptForMe ??
                                    "",
                                EncryptionHelper.convertStringToPrivateKey(
                                    decrypted_private_key),
                              )
                            : decrypt(
                                widget.chatModel.lastMessage
                                        ?.messageEncryptForReveiver ??
                                    "",
                                EncryptionHelper.convertStringToPrivateKey(
                                    decrypted_private_key),
                              ),
                    style: TextStyle(
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Text(
              DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(
                  widget.chatModel.lastMessage?.createdAt ?? 0)),
            ),
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
