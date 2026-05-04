import 'package:flutter/material.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

String uri = 'https://ecrm-server.onrender.com';
// String uri = 'http://172.16.1.202:3000'; // mang phuong dong
// String uri = 'http://192.168.0.106:3000'; // mang cty

// String uri = 'http://192.168.1.39:3000'; // mang cty
// String uri = 'http://192.168.1.13:3000'; // mang o nha

class GlobalVariables {
  // COLORS
  static const appBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 96, 158, 230),
      Color.fromARGB(255, 204, 210, 218),
    ],
    stops: [0.5, 1.0],
  );

  static const primaryColor = Color.fromARGB(255, 96, 158, 230);
  static const secondaryColor = Color.fromRGBO(255, 153, 0, 1);
  static const backgroundColor = Colors.white;
  static const Color greyBackgroundCOlor = Color(0xffebecee);
  static const unselectedNavBarColor = Colors.black87;

  // STATIC IMAGES
  static const List<String> carouselImages = [
    'assets/images/banner_1.png',
    'assets/images/banner_2.png',
    'assets/images/banner_3.jpg',
    'assets/images/banner_4.jpg',
    'assets/images/banner_5.png',
  ];

  static const List<Map<String, String>> categoryImages = [
    {
      'title': 'Điện thoại',
      'image': 'assets/images/mobiles.jpeg',
    },
    {
      'title': 'Đồ thiết yếu',
      'image': 'assets/images/essentials.jpeg',
    },
    {
      'title': 'Đồ gia dụng',
      'image': 'assets/images/appliances.jpeg',
    },
    {
      'title': 'Sách',
      'image': 'assets/images/books.jpeg',
    },
    {
      'title': 'Thời trang',
      'image': 'assets/images/fashion.jpeg',
    },
  ];

  // SPEECH TO TEXT
  static late SpeechToTextProvider speechProvider;

  static List<User> branches = [];
  static bool checkUserExist = false;
  static dynamic DEVICE_INFO;
  static String DEVICE_ID = "";
}
