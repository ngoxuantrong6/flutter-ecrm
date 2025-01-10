import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_ecrm/models/product.dart';

class OwnFileCard extends StatelessWidget {
  const OwnFileCard(
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
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: InkWell(
          onTap: () {
            if (product != null) {
              Navigator.pushNamed(
                context,
                ProductDetailScreen.routeName,
                arguments: product?.id,
              );
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height / 2.3,
            width: MediaQuery.of(context).size.width / 1.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: GlobalVariables.primaryColor,
            ),
            child: Card(
              margin: EdgeInsets.all(3),
              color: GlobalVariables.primaryColor,
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
                    child: isUrl(path)
                        ? CachedNetworkImage(
                            imageUrl: path,
                            fit: BoxFit.contain,
                          )
                        : imageFromBase64String(
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
