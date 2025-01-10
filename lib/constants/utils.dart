import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/common/widgets/popup_notification_custom.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/services/account_services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:crypto/crypto.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

List<File> images = [];
Future<List<XFile>> selectImages2() async {
  List<XFile> imageFileList = [];
  final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
  if (selectedImages!.isNotEmpty) {
    imageFileList.addAll(selectedImages);
  }
  return imageFileList;
  // setState(() {});
}

Future<List<File>> pickImages() async {
  List<File> images = [];
  try {
    var status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      var files = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (files != null && files.files.isNotEmpty) {
        for (int i = 0; i < files.files.length; i++) {
          images.add(File(files.files[i].path!));
        }
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  return images;
}

final numberFormat = NumberFormat("#,##0", "vi_VN");
String formatPrice(int number) {
  final priceFormat = numberFormat.format(number);
  return priceFormat;
}

String formatPriceInt(int number) {
  final priceFormat = numberFormat.format(number);
  return priceFormat;
}

bool isUrl(String input) {
  final urlPattern = r'^(https?:\/\/)?[\w\-]+(\.[\w\-]+)+[/#?]?.*$';
  final result = RegExp(urlPattern).hasMatch(input);
  return result;
}

Image imageFromBase64String(String base64String,
    {BoxFit? fit, double? height, double? width}) {
  return Image.memory(
    base64Decode(base64String),
    fit: fit ?? BoxFit.cover,
    height: height,
    width: width,
  );
}

const key = "16CharSecretKey!";
const int TIME_TO_LOGOUT = 300000;

Future<String?> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    // import 'dart:io'
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    GlobalVariables.DEVICE_INFO = iosDeviceInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    GlobalVariables.DEVICE_INFO = androidDeviceInfo;
    return androidDeviceInfo.id; // unique ID on Android
  }
}

String sha256Convert(String value) {
  return sha256.convert(utf8.encode(value)).toString();
}

Future<bool> deviceRootJailbreak(BuildContext context) async {
  try {
    bool jailbroken = await FlutterJailbreakDetection.jailbroken;

    if (jailbroken) {
      PopupNotificationCustom.showMessgae(
        context: context,
        title: 'Phát hiện thiết bị đã bị root/jailbreak',
        message:
            'eCRM Pro không hỗ trợ trên thiết bị đã bị root hoặc jailbreak',
        buttonTitleLeft: "Đồng ý",
        hiddenButtonRight: true,
        pressButtonLeft: () => AccountServices().logOut(context),
      );
    }
    return jailbroken;
  } catch (e) {
    print("Có lỗi xảy ra: $e");
    return false;
  }
}
