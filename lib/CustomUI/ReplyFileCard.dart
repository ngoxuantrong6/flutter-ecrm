import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ecrm/features/admin/screens/edit_product_screen.dart';
import 'package:flutter_ecrm/models/product.dart';

class ReplyFileCard extends StatelessWidget {
  const ReplyFileCard(
      {Key? key,
      required this.message,
      required this.time,
      required this.path,
      this.product})
      : super(key: key);
  final String path;
  final String message;
  final String time;
  final Product? product;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: InkWell(
          onTap: () {
            if (product != null) {
              Navigator.pushNamed(
                context,
                EditProductScreen.routeName,
                arguments: product,
              );
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height / 2.3,
            width: MediaQuery.of(context).size.width / 1.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.teal[400],
            ),
            child: Card(
              margin: EdgeInsets.all(3),
              color: Colors.teal[400],
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    // child: Image.file(
                    //   File(path),
                    //   fit: BoxFit.fitHeight,
                    // ),
                    child: Image.network(
                      path,
                      fit: BoxFit.contain,
                    ),
                  ),
                  message.length > 0
                      ? Container(
                          height: 40,
                          padding: EdgeInsets.only(
                            left: 15,
                            top: 8,
                          ),
                          child: Text(
                            message,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
