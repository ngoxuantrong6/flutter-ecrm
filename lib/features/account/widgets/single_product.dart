import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_ecrm/constants/utils.dart';

class SingleProduct extends StatelessWidget {
  final String image;
  const SingleProduct({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: GlobalVariables.primaryColor,
            width: 0.2,
          ),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              spreadRadius: 1,
              blurRadius: 2,
              color: GlobalVariables.primaryColor.withOpacity(0.25),
              offset: const Offset(2, 2),
            ),
          ],
          color: Colors.white,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.45,
          padding: const EdgeInsets.all(10),
          child: isUrl(image)
              ? CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.fitHeight,
                  width: MediaQuery.of(context).size.width * 0.45,
                )
              : imageFromBase64String(
                  image,
                  fit: BoxFit.fitHeight,
                  width: MediaQuery.of(context).size.width * 0.45,
                ),
        ),
      ),
    );
  }
}
