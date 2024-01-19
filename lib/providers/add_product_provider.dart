import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductProvider extends ChangeNotifier {
  String _category = 'Điện thoại';
  List<XFile> _images = [];

  String get category => _category;
  List<XFile> get images => _images;

  void setCategory(String category) {
    _category = category;
    notifyListeners();
  }

  void setImages(List<XFile> images) {
    _images = images;
    notifyListeners();
  }
}
