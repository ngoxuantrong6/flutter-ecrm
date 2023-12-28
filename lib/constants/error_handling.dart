import 'dart:convert';

import 'package:amazon_clone_tutorial/common/widgets/loading_show_able.dart';
import 'package:amazon_clone_tutorial/constants/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  switch (response.statusCode) {
    case 200:
      LoadingShowAble.forceHide();
      onSuccess();
      break;
    case 400:
      LoadingShowAble.forceHide();
      showSnackBar(context, jsonDecode(response.body)['msg']);
      break;
    case 500:
      LoadingShowAble.forceHide();
      showSnackBar(context, jsonDecode(response.body)['error']);
      break;
    default:
      LoadingShowAble.forceHide();
      showSnackBar(context, response.body);
  }
}
