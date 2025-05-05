import 'dart:convert';

import 'package:flutter_ecrm/constants/error_handling.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class HomeServices {
  /// Hàm lấy danh sách sản phẩm theo danh mục và chi nhánh
  Future<List<Product>> fetchCategoryProducts({
    required BuildContext context,
    required String category,
    required String branchId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context,
        listen: false); // truy cập token xác thực của người dùng đó
    List<Product> productList = []; // Danh sách sản phẩm sẽ được lưu ở đây
    try {
      // Gửi yêu cầu GET đến API để lấy danh sách sản phẩm theo danh mục và chi nhánh
      http.Response res = await http.get(
        Uri.parse('$uri/api/products?category=$category&branchId=$branchId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // Định dạng JSON
          'x-auth-token': userProvider.user.token, // Token xác thực người dùng
        },
      );

      // Xử lý phản hồi HTTP
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // Chuyển đổi dữ liệu JSON từ response thành danh sách Product
          List<dynamic> responseData =
              jsonDecode(res.body); // Chuyển JSON thành danh sách
          productList = responseData
              .map((data) => Product.fromJson(jsonEncode(data)))
              .toList(); // Chuyển từng phần tử thành Product
        },
      );
    } catch (e) {
      showSnackBar(context,
          "Lỗi khi tải sản phẩm: ${e.toString()}"); // Hiển thị lỗi nếu có
    }
    return productList; // Trả về danh sách sản phẩm
  }

  /// Hàm lấy sản phẩm Deal of the Day (sản phẩm hot nhất trong ngày)
  Future<Product> fetchDealOfDay({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Tạo sản phẩm mặc định phòng trường hợp API không trả về dữ liệu
    Product product = Product(
      name: '',
      description: '',
      quantity: 0,
      images: [],
      category: '',
      price: 0,
    );

    try {
      // Gửi yêu cầu GET để lấy sản phẩm hot nhất trong ngày
      http.Response res = await http.get(
        Uri.parse('$uri/api/deal-of-day'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // Định dạng JSON
          'x-auth-token': userProvider.user.token, // Token xác thực người dùng
        },
      );

      // Xử lý phản hồi HTTP
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          product = Product.fromJson(res.body); // Chuyển đổi JSON thành Product
        },
      );
    } catch (e) {
      showSnackBar(context,
          "Lỗi khi tải sản phẩm hot: ${e.toString()}"); // Hiển thị lỗi nếu có
    }
    return product; // Trả về sản phẩm hot nhất trong ngày
  }

  /// Hàm lấy danh sách chi nhánh
  Future<List<User>> getListBranch({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context,
        listen: false); // xác thực token của người dùng
    List<User> branchList = []; // Danh sách chi nhánh sẽ được lưu ở đây
    try {
      // Gửi yêu cầu GET đến API để lấy danh sách chi nhánh
      http.Response res = await http.get(
        Uri.parse('$uri/api/branches'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // Định dạng JSON
          'x-auth-token': userProvider.user.token, // Token xác thực người dùng
        },
      );

      // Xử lý phản hồi HTTP
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // Chuyển đổi dữ liệu JSON từ response thành danh sách User
          List<dynamic> responseData =
              jsonDecode(res.body); // Chuyển JSON thành danh sách
          branchList = responseData
              .map((data) => User.fromJson(jsonEncode(data)))
              .toList(); // Chuyển từng phần tử thành User
        },
      );
    } catch (e) {
      showSnackBar(context,
          "Lỗi khi tải danh sách chi nhánh: ${e.toString()}"); // Hiển thị lỗi nếu có
    }
    return branchList; // Trả về danh sách chi nhánh
  }
}
