import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

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
String formatPrice(double number) {
  final priceFormat = numberFormat.format(number);
  return priceFormat;
}

String formatPriceInt(int number) {
  final priceFormat = numberFormat.format(number);
  return priceFormat;
}
