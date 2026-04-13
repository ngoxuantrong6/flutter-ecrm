import 'dart:convert';
import 'dart:developer';
import 'package:flutter_ecrm/Model/ChatModel.dart';
import 'package:flutter_ecrm/common/widgets/loading_show_able.dart';
import 'package:flutter_ecrm/constants/error_handling.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ChatPageServices {
  Future<List<ChatModel>> getConversations({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<ChatModel> conversationList = [];
    try {
      http.Response res = await http
          .get(Uri.parse('$uri/api/conversation/list'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          log("mmmmmmmmmmmmmmm ${res.body}");
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            conversationList.add(
              ChatModel.fromJson(
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
    return conversationList;
  }
}
