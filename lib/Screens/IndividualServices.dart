import 'dart:convert';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_ecrm/Model/MessageModel.dart';
import 'package:flutter_ecrm/common/widgets/loading_show_able.dart';
import 'package:flutter_ecrm/constants/error_handling.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class IndividualServices {
  Future<List<MessageModel>> getMessages({
    required BuildContext context,
    required String chatUserId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<MessageModel> messageList = [];
    try {
      http.Response res = await http
          .get(Uri.parse('$uri/api/message/get-message/$chatUserId'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            messageList.add(
              MessageModel.fromJson(
                jsonEncode(
                  jsonDecode(res.body)[i],
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return messageList;
  }

  Future<MessageModel> sendMessage({
    required BuildContext context,
    required String receiverId,
    String? message,
    XFile? image,
    Product? product,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var messageModel = MessageModel(
        id: "", senderId: "", receiverId: "", message: "", createdAt: 0);

    try {
      LoadingShowAble.showLoading();
      final cloudinary = CloudinaryPublic('denz4r8iw', 'mr3ntizn');
      String? imageUrl;

      if (image != null) {
        CloudinaryResponse cloudRes = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path, folder: message ?? ""),
        );
        imageUrl = cloudRes.secureUrl;
      }

      http.Response res = await http.post(
        Uri.parse('$uri/api/message/send-message/$receiverId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: json.encode({
          'message': message,
          'image': product?.images[0] ?? imageUrl,
          'productId': product?.id,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          messageModel =
              MessageModel.fromJson(jsonEncode(jsonDecode(res.body)));
          // showSnackBar(context, 'Gửi tin nhắn thành công!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return messageModel;
  }
}
