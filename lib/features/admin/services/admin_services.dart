import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_ecrm/common/widgets/loading_show_able.dart';
import 'package:flutter_ecrm/constants/error_handling.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/admin/models/sales.dart';
import 'package:flutter_ecrm/models/branch.dart';
import 'package:flutter_ecrm/models/order.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/add_product_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AdminServices {
  // Hàm thực hiện yêu cầu HTTP với timeout
  Future<http.Response> _makeRequestWithTimeout(
    Uri uri,
    Map<String, String> headers, {
    String? body,
    String method = 'POST', // Thêm tham số method, mặc định là POST
  }) async {
    final client = http.Client();
    try {
      if (method == 'POST') {
        return await client
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw Exception(
              'Request timeout. Please check your internet connection.');
        });
      } else if (method == 'PATCH') {
        return await client
            .patch(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw Exception(
              'Request timeout. Please check your internet connection.');
        });
      } else if (method == 'DELETE') {
        return await client
            .delete(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw Exception(
              'Request timeout. Please check your internet connection.');
        });
      } else {
        return await client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 10), onTimeout: () {
          throw Exception(
              'Request timeout. Please check your internet connection.');
        });
      }
    } finally {
      client.close();
    }
  }

  // Hàm xử lý danh sách sản phẩm trên isolate để tối ưu hiệu suất
  static List<Product> _parseProducts(List<dynamic> productData) {
    return productData
        .map((product) => Product.fromJson(jsonEncode(product)))
        .toList();
  }

  // Hàm xử lý danh sách đơn hàng trên isolate
  static List<Order> _parseOrders(List<dynamic> orderData) {
    return orderData.map((order) => Order.fromJson(jsonEncode(order))).toList();
  }

  // Hàm xử lý danh sách chi nhánh trên isolate
  static List<User> _parseBranches(List<dynamic> branchData) {
    return branchData
        .map((branch) => User.fromJson(jsonEncode(branch)))
        .toList();
  }

  // Thêm sản phẩm
  Future<void> sellProduct({
    required BuildContext context,
    required String name,
    required String description,
    required int price,
    required int quantity,
    required String category,
    required List<XFile> images,
    required String branchId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final addProductProvider =
        Provider.of<AddProductProvider>(context, listen: false);

    try {
      LoadingShowAble.showLoading();
      final cloudinary = CloudinaryPublic('denz4r8iw', 'mr3ntizn');
      List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        CloudinaryResponse res = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(images[i].path, folder: name),
        );
        imageUrls.add(res.secureUrl); // Chỉ lưu URL thay vì Base64
      }

      Product product = Product(
        name: name,
        description: description,
        quantity: quantity,
        images: imageUrls, // Sử dụng URL trực tiếp
        category: category,
        price: price,
        branchId: branchId,
      );

      http.Response res = await _makeRequestWithTimeout(
        Uri.parse('$uri/admin/add-product'),
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
        method: 'POST',
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          if (true) {
            showSnackBar(context, 'Đã thêm sản phẩm thành công!');
            addProductProvider.setCategory('Điện thoại');
            addProductProvider.setImages([]);
            Navigator.of(context).pop(true);
          }
        },
      );
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    } finally {
      LoadingShowAble.hideLoading();
    }
  }

  // Sửa sản phẩm
  Future<void> editProduct({
    required BuildContext context,
    required String productId,
    required String name,
    required String description,
    required int price,
    required int quantity,
    required String category,
    required List<String> images,
    required String branchId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      LoadingShowAble.showLoading();

      // Đảm bảo description không rỗng
      final validDescription =
          description.isEmpty ? "Không có mô tả" : description;

      // Tạo đối tượng Product
      final product = Product(
        name: name,
        description: validDescription,
        quantity: quantity,
        images: images,
        category: category,
        price: price,
        branchId: branchId,
      );

      // Gửi yêu cầu PATCH
      final res = await _makeRequestWithTimeout(
        Uri.parse('$uri/admin/edit-product/$productId'),
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
        method: 'PATCH', // Sử dụng PATCH
      );

      // Xử lý phản hồi từ server
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          if (true) {
            showSnackBar(context, 'Đã sửa sản phẩm thành công!');
            Navigator.of(context).pop(true);
          }
        },
      );
    } catch (e) {
      if (true) {
        showSnackBar(context, 'Lỗi khi sửa sản phẩm: ${e.toString()}');
      }
      rethrow;
    } finally {
      LoadingShowAble.hideLoading();
    }
  }

  // Lấy tất cả sản phẩm (với caching)
  Future<List<Product>> fetchAllProducts(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    final prefs = await SharedPreferences.getInstance();
    String? cachedProducts = prefs.getString('cached_products');

    try {
      if (cachedProducts != null) {
        productList = _parseProducts(jsonDecode(cachedProducts));
      } else {
        http.Response res = await _makeRequestWithTimeout(
          Uri.parse('$uri/admin/get-products'),
          {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          },
          method: 'GET',
        );

        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            final List<dynamic> productData = jsonDecode(res.body);
            productList = _parseProducts(productData);
            prefs.setString('cached_products', jsonEncode(productData));
            if (true && productList.isNotEmpty) {
              showSnackBar(context, 'Tải danh sách sản phẩm thành công!');
            }
          },
        );
      }
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    }
    return productList;
  }

  // Lấy sản phẩm theo chi nhánh
  Future<List<Product>> fetchBranchProducts({
    required BuildContext context,
    required String branchId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    final prefs = await SharedPreferences.getInstance();
    String? cachedProducts = prefs.getString('cached_products_$branchId');

    try {
      if (cachedProducts != null) {
        productList = _parseProducts(jsonDecode(cachedProducts));
      } else {
        http.Response res = await _makeRequestWithTimeout(
          Uri.parse('$uri/admin/get-products?branchId=$branchId'),
          {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          },
          method: 'GET',
        );

        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            final List<dynamic> productData = jsonDecode(res.body);
            productList = _parseProducts(productData);
            prefs.setString(
                'cached_products_$branchId', jsonEncode(productData));
            if (true && productList.isNotEmpty) {
              showSnackBar(
                  context, 'Tải danh sách sản phẩm chi nhánh thành công!');
            }
          },
        );
      }
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    }
    return productList;
  }

  // Xóa sản phẩm
  Future<void> deleteProduct({
    required BuildContext context,
    required Product product,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await _makeRequestWithTimeout(
        Uri.parse('$uri/admin/delete-product'),
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': product.id}),
        method: 'DELETE', // Sử dụng DELETE
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          if (true) {
            onSuccess();
            showSnackBar(context, 'Xóa sản phẩm thành công!');
          }
        },
      );
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    }
  }

  // Lấy tất cả đơn hàng
  Future<List<Order>> fetchAllOrders(
      BuildContext context, String branchId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];
    final prefs = await SharedPreferences.getInstance();
    String? cachedOrders = prefs.getString('cached_orders_$branchId');
    DateTime? cacheTime =
        prefs.getString('cached_orders_time_$branchId') != null
            ? DateTime.parse(prefs.getString('cached_orders_time_$branchId')!)
            : null;

    // Kiểm tra cache
    if (cachedOrders != null &&
        cacheTime != null &&
        DateTime.now().difference(cacheTime).inHours < 1) {
      final cachedData = jsonDecode(cachedOrders);
      if (cachedData is List) {
        orderList = _parseOrders(cachedData);
      } else {
        throw Exception('Dữ liệu cache không phải là danh sách: $cachedData');
      }
    } else {
      try {
        http.Response res = await _makeRequestWithTimeout(
          Uri.parse('$uri/admin/get-orders?branchId=$branchId'),
          {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          },
          method: 'GET',
        );

        debugPrint('fetchAllOrders Response status: ${res.statusCode}');
        debugPrint('fetchAllOrders Response body: ${res.body}');

        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            if (res.body.isNotEmpty) {
              final dynamic responseData = jsonDecode(res.body);
              List<dynamic> orderData;

              // Kiểm tra định dạng phản hồi
              if (responseData is List) {
                orderData = responseData;
              } else if (responseData is Map<String, dynamic> &&
                  responseData.containsKey('orders')) {
                orderData = responseData['orders'];
                if (orderData is! List) {
                  throw Exception(
                      'Dữ liệu orders trong phản hồi không phải là danh sách: $orderData');
                }
              } else {
                throw Exception(
                    'Dữ liệu trả về không đúng định dạng: $responseData');
              }

              orderList = _parseOrders(orderData);
              prefs.setString('cached_orders_$branchId', jsonEncode(orderData));
              prefs.setString('cached_orders_time_$branchId',
                  DateTime.now().toIso8601String());
              if (true && orderList.isNotEmpty) {
                showSnackBar(context, 'Tải danh sách đơn hàng thành công!');
              }
            } else {
              throw Exception('Phản hồi từ server trống');
            }
          },
        );
      } catch (e) {
        if (true) {
          showSnackBar(context, 'Lỗi khi tải đơn hàng: ${e.toString()}');
        }
        rethrow;
      }
    }
    return orderList;
  }

  // Lấy chi tiết đơn hàng
  Future<Order> getOrderDetail(BuildContext context, String orderId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Order order = Order(
      id: "",
      products: [],
      quantity: [],
      address: "",
      userId: "",
      orderedAt: 0,
      status: 0,
      totalPrice: 0,
    );

    try {
      http.Response res = await _makeRequestWithTimeout(
        Uri.parse('$uri/admin/get-order-detail'),
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': orderId}),
        method: 'POST', // Sử dụng POST
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          order = Order.fromJson(res.body);
        },
      );
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    }
    return order;
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> changeOrderStatus({
    required BuildContext context,
    required int status,
    required Order order,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      LoadingShowAble.showLoading();
      http.Response res = await _makeRequestWithTimeout(
        Uri.parse('$uri/admin/change-order-status'),
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': order.id, 'status': status}),
        method: 'PATCH', // Sử dụng PATCH
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          if (true) {
            onSuccess();
            showSnackBar(context, 'Cập nhật trạng thái đơn hàng thành công!');
          }
        },
      );
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    } finally {
      LoadingShowAble.hideLoading();
    }
  }

  // Lấy doanh thu
  Future<Map<String, dynamic>> getEarnings(
      BuildContext context, String branchId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Sales> sales = [];
    int totalEarning = 0;
    final prefs = await SharedPreferences.getInstance();
    String? cachedEarnings = prefs.getString('cached_earnings_$branchId');

    try {
      if (cachedEarnings != null) {
        final data = jsonDecode(cachedEarnings);
        totalEarning = data['totalEarnings'];
        sales = (data['sales'] as List)
            .map((item) => Sales(item['label'], item['earning']))
            .toList();
      } else {
        http.Response res = await _makeRequestWithTimeout(
          Uri.parse('$uri/admin/analytics?branchId=$branchId'),
          {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          },
          method: 'GET',
        );

        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            var response = jsonDecode(res.body);
            totalEarning = response['totalEarnings'];
            sales = [
              Sales('Điện thoại', response['mobileEarnings']),
              Sales('Đ.thiết yếu', response['essentialEarnings']),
              Sales('Đ.gia dụng', response['applianceEarnings']),
              Sales('Sách', response['booksEarnings']),
              Sales('Thời trang', response['fashionEarnings']),
            ];
            prefs.setString(
              'cached_earnings_$branchId',
              jsonEncode({
                'totalEarnings': totalEarning,
                'sales': sales
                    .map((s) => {'label': s.label, 'earning': s.earning})
                    .toList()
              }),
            );
          },
        );
      }
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    }
    return {
      'sales': sales,
      'totalEarnings': totalEarning,
    };
  }

  // Thêm chi nhánh
  Future<void> addBranch({
    required BuildContext context,
    required String branchName,
    required String address,
    required String email,
    required String password,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      LoadingShowAble.showLoading();
      Branch branch = Branch(
        branchName: branchName,
        address: address,
        email: email,
        password: password,
      );

      http.Response res = await _makeRequestWithTimeout(
        Uri.parse('$uri/admin/add-branch'),
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: branch.toJson(),
        method: 'POST',
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          if (true) {
            showSnackBar(context, 'Đã thêm chi nhánh thành công!');
            Navigator.of(context).pop(true);
          }
        },
      );
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    } finally {
      LoadingShowAble.hideLoading();
    }
  }

  // Sửa chi nhánh
  Future<void> editBranch({
    required BuildContext context,
    required String branchName,
    required String address,
    required String email,
    required String branchId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      LoadingShowAble.showLoading();
      User user = User(
        id: branchId,
        name: branchName,
        email: email,
        password: userProvider.user.password,
        address: address,
        type: "branch",
        token: userProvider.user.token,
        cart: [],
        publicKey: "",
        privateKey: "",
      );

      http.Response res = await _makeRequestWithTimeout(
        Uri.parse('$uri/admin/edit-branch/$branchId'),
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: user.toJson(),
        method: 'PATCH', // Sử dụng PATCH
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          if (true) {
            showSnackBar(context, 'Đã sửa chi nhánh thành công!');
            Navigator.of(context).pop(true);
          }
        },
      );
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    } finally {
      LoadingShowAble.hideLoading();
    }
  }

  // Lấy tất cả chi nhánh
  Future<List<User>> fetchAllBranches(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<User> branchList = [];
    final prefs = await SharedPreferences.getInstance();
    String? cachedBranches = prefs.getString('cached_branches');

    try {
      if (cachedBranches != null) {
        branchList = _parseBranches(jsonDecode(cachedBranches));
      } else {
        http.Response res = await _makeRequestWithTimeout(
          Uri.parse('$uri/admin/get-branches'),
          {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          },
          method: 'GET',
        );

        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () {
            final List<dynamic> branchData = jsonDecode(res.body);
            branchList = _parseBranches(branchData);
            prefs.setString('cached_branches', jsonEncode(branchData));
            if (true && branchList.isNotEmpty) {
              showSnackBar(context, 'Tải danh sách chi nhánh thành công!');
            }
          },
        );
      }
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    }
    return branchList;
  }

  // Lấy chi tiết chi nhánh
  Future<User> getBranchDetailForAdmin({
    required BuildContext context,
    required String branchId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    User branch = User(
      id: "",
      name: "",
      email: "",
      password: "",
      address: "",
      type: "",
      token: "",
      cart: [],
      publicKey: "",
      privateKey: "",
    );

    try {
      http.Response res = await _makeRequestWithTimeout(
        Uri.parse('$uri/admin/get-branch/$branchId'),
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        method: 'GET',
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          branch = User.fromJson(jsonEncode(jsonDecode(res.body)));
        },
      );
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    }
    return branch;
  }

  // Xóa chi nhánh
  Future<void> deleteBranch({
    required BuildContext context,
    required User branch,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await _makeRequestWithTimeout(
        Uri.parse('$uri/admin/delete-branch'),
        {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({'id': branch.id}),
        method: 'DELETE', // Sử dụng DELETE
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          if (true) {
            onSuccess();
            showSnackBar(context, 'Xóa chi nhánh thành công!');
          }
        },
      );
    } catch (e) {
      if (true) {
        showSnackBar(context, e.toString());
      }
      rethrow;
    }
  }
}
