import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/CustomUI/OwnFileCard.dart';
import 'package:flutter_ecrm/CustomUI/OwnMessgaeCrad.dart';
import 'package:flutter_ecrm/CustomUI/ReplyCard.dart';
import 'package:flutter_ecrm/CustomUI/ReplyFileCard.dart';
import 'package:flutter_ecrm/Pages/CameraPage.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_ecrm/providers/individual_page_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IndividualPage extends StatefulWidget {
  static const String routeName = '/individual-page';
  IndividualPage({Key? key, required this.individualPageArguments})
      : super(key: key);
  final IndividualPageArguments individualPageArguments;

  @override
  _IndividualPageState createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final individualPageProvider = context.watch<IndividualPageProvider>();
    return Stack(
      children: [
        // Image.asset(
        //   "assets/whatsapp_Back.png",
        //   height: MediaQuery.of(context).size.height,
        //   width: MediaQuery.of(context).size.width,
        //   fit: BoxFit.cover,
        // ),
        Scaffold(
          backgroundColor: GlobalVariables.backgroundColor,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: AppBar(
              leadingWidth: 70,
              titleSpacing: 0,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 24,
                    ),
                    CircleAvatar(
                      child: Image.asset(
                        "assets/images/img_loading_avatar.png",
                        height: 36,
                        width: 36,
                      ),
                      radius: 20,
                      backgroundColor: Colors.blueGrey,
                    ),
                  ],
                ),
              ),
              title: InkWell(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.individualPageArguments.receiver.name,
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Text(
                      //   "last seen today at 12:05",
                      //   style: TextStyle(
                      //     fontSize: 13,
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
              // actions: [
              //   IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
              //   IconButton(icon: Icon(Icons.call), onPressed: () {}),
              //   PopupMenuButton<String>(
              //     padding: EdgeInsets.all(0),
              //     onSelected: (value) {
              //       print(value);
              //     },
              //     itemBuilder: (BuildContext contesxt) {
              //       return [
              //         PopupMenuItem(
              //           child: Text("View Contact"),
              //           value: "View Contact",
              //         ),
              //         PopupMenuItem(
              //           child: Text("Media, links, and docs"),
              //           value: "Media, links, and docs",
              //         ),
              //         PopupMenuItem(
              //           child: Text("Whatsapp Web"),
              //           value: "Whatsapp Web",
              //         ),
              //         PopupMenuItem(
              //           child: Text("Search"),
              //           value: "Search",
              //         ),
              //         PopupMenuItem(
              //           child: Text("Mute Notification"),
              //           value: "Mute Notification",
              //         ),
              //         PopupMenuItem(
              //           child: Text("Wallpaper"),
              //           value: "Wallpaper",
              //         ),
              //       ];
              //     },
              //   ),
              // ],
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: WillPopScope(
              child: Column(
                children: [
                  Expanded(
                    // height: MediaQuery.of(context).size.height - 150,
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: individualPageProvider.scrollController,
                      itemCount: individualPageProvider.messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == individualPageProvider.messages.length) {
                          return Container(
                            height: 70,
                          );
                        }
                        if (individualPageProvider.messages[index].senderId ==
                            userProvider.user.id) {
                          if (individualPageProvider
                              .messages[index].image!.isNotEmpty) {
                            return OwnFileCard(
                              path:
                                  individualPageProvider.messages[index].image!,
                              message: individualPageProvider
                                      .messages[index].message ??
                                  "",
                              time: DateFormat('HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    individualPageProvider
                                        .messages[index].createdAt),
                              ),
                              product: individualPageProvider
                                  .messages[index].product,
                            );
                          } else {
                            return OwnMessageCard(
                              message: individualPageProvider
                                      .messages[index].message ??
                                  "",
                              time: DateFormat('HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    individualPageProvider
                                        .messages[index].createdAt),
                              ),
                            );
                          }
                        } else {
                          if (individualPageProvider
                              .messages[index].image!.isNotEmpty) {
                            return ReplyFileCard(
                              path:
                                  individualPageProvider.messages[index].image!,
                              message: individualPageProvider
                                      .messages[index].message ??
                                  "",
                              time: DateFormat('HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    individualPageProvider
                                        .messages[index].createdAt),
                              ),
                              product: individualPageProvider
                                  .messages[index].product,
                            );
                          } else {
                            return ReplyCard(
                              message: individualPageProvider
                                      .messages[index].message ??
                                  "",
                              time: DateFormat('HH:mm').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    individualPageProvider
                                        .messages[index].createdAt),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 60,
                                child: Card(
                                  margin: EdgeInsets.only(
                                      left: 2, right: 2, bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: TextFormField(
                                    controller: _messageController,
                                    focusNode: focusNode,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    onChanged: (value) {
                                      if (value.length > 0) {
                                        setState(() {
                                          sendButton = true;
                                        });
                                      } else {
                                        setState(() {
                                          sendButton = false;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Nhập tin nhắn",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      prefixIcon: IconButton(
                                        icon: Icon(
                                          show
                                              ? Icons.keyboard
                                              : Icons.emoji_emotions_outlined,
                                        ),
                                        onPressed: () {
                                          if (!show) {
                                            focusNode.unfocus();
                                            focusNode.canRequestFocus = false;
                                          }
                                          setState(() {
                                            show = !show;
                                          });
                                        },
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // IconButton(
                                          //   icon: Icon(Icons.attach_file),
                                          //   onPressed: () {
                                          //     showModalBottomSheet(
                                          //         backgroundColor:
                                          //             Colors.transparent,
                                          //         context: context,
                                          //         builder: (builder) =>
                                          //             bottomSheet());
                                          //   },
                                          // ),
                                          IconButton(
                                            icon: Icon(Icons.camera_alt),
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          CameraPage(
                                                            sender: userProvider
                                                                .user,
                                                            receiver: widget
                                                                .individualPageArguments
                                                                .receiver,
                                                            provider:
                                                                individualPageProvider,
                                                          )));
                                            },
                                          ),
                                        ],
                                      ),
                                      contentPadding: EdgeInsets.all(5),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8,
                                  right: 2,
                                  left: 2,
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: GlobalVariables.primaryColor,
                                  child: IconButton(
                                    icon: Icon(
                                      sendButton ? Icons.send : Icons.send,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      if (sendButton) {
                                        individualPageProvider.scrollController
                                            .animateTo(
                                                individualPageProvider
                                                    .scrollController
                                                    .position
                                                    .maxScrollExtent,
                                                duration: const Duration(
                                                    milliseconds: 1000),
                                                curve: Curves.easeOut);
                                        individualPageProvider.sendMessage(
                                            context,
                                            user: userProvider.user,
                                            messageController:
                                                _messageController,
                                            receiver: widget
                                                .individualPageArguments
                                                .receiver);
                                        _messageController.clear();
                                        setState(() {
                                          sendButton = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          show ? emojiSelect() : Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onWillPop: () {
                if (show) {
                  setState(() {
                    show = false;
                  });
                } else {
                  Navigator.pop(context);
                }
                return Future.value(false);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.location_pin, Colors.teal, "Location"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.person, Colors.blue, "Contact"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }

  Widget emojiSelect() {
    return Expanded(
      child: EmojiPicker(
          config: Config(
            columns: 7,
          ),
          // rows: 4,
          // columns: 7,
          onEmojiSelected: (emoji, category) {
            print(emoji);
            setState(() {
              _messageController.text = _messageController.text + emoji!.name;
            });
          }),
    );
  }
}
