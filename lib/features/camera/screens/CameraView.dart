import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/individual_page_provider.dart';

class CameraViewPage extends StatelessWidget {
  const CameraViewPage({
    Key? key,
    required this.file,
    required this.sender,
    required this.receiver,
    required this.provider,
  }) : super(key: key);
  final XFile file;
  final User sender;
  final User receiver;
  final IndividualPageProvider provider;

  @override
  Widget build(BuildContext context) {
    TextEditingController _captionController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              icon: Icon(
                Icons.crop_rotate,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.title,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.edit,
                size: 27,
              ),
              onPressed: () {}),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: Image.file(
                File(file.path),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black38,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: TextFormField(
                  controller: _captionController,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  maxLines: 6,
                  minLines: 1,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Add Caption....",
                      prefixIcon: Icon(
                        Icons.add_photo_alternate,
                        color: Colors.white,
                        size: 27,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          provider.sendMessage(context,
                              user: sender,
                              messageController: _captionController,
                              receiver: receiver,
                              image: file,
                              fromCameraView: true);
                        },
                        child: CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.tealAccent[700],
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 27,
                          ),
                        ),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
