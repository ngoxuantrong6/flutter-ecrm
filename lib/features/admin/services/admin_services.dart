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

class AdminServices {
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
      String base64Image = "";
      List<String> base64Images = [];

      for (int i = 0; i < images.length; i++) {
        CloudinaryResponse res = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(images[i].path, folder: name),
        );
        imageUrls.add(res.secureUrl);
        base64Image = await encodeImageFromUrl(res.secureUrl);
        base64Images.add(base64Image);
      }

      Product product = Product(
        name: name,
        description: description,
        quantity: quantity,
        // images: imageUrls,
        images: base64Images,
        category: category,
        price: price,
        branchId: branchId,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/admin/add-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Đã thêm sản phẩm thành công!');
          addProductProvider.setCategory('Điện thoại');
          addProductProvider.setImages([]);
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<String> encodeImageFromUrl(String imageUrl) async {
    try {
      // Tải ảnh từ URL
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Lấy dữ liệu byte từ ảnh
        Uint8List imageBytes = response.bodyBytes;

        // Mã hóa Base64
        String base64Image = base64Encode(imageBytes);
        return base64Image;
      } else {
        throw Exception("Failed to load image");
      }
    } catch (e) {
      print("Error encoding image: $e");
      return "";
    }
  }

  void editProduct({
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

      Product product = Product(
        name: name,
        description: description,
        quantity: quantity,
        images: images,
        category: category,
        price: price,
        branchId: branchId,
      );

      http.Response res = await http.patch(
        Uri.parse('$uri/admin/edit-product/$productId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Đã sửa sản phẩm thành công!');
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get all the products
  Future<List<Product>> fetchAllProducts(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    try {
      http.Response res =
          await http.get(Uri.parse('$uri/admin/get-products'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            productList.add(
              Product.fromJson(
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
    return productList;
  }

  Future<List<Product>> fetchBranchProducts({
    required BuildContext context,
    required String branchId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Product> productList = [];
    try {
      http.Response res = await http.get(
          Uri.parse('$uri/admin/get-products?branchId=$branchId'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            productList.add(
              Product.fromJson(
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
    return productList;
  }

  Future<Product> getProductDetailForAdmin({
    required BuildContext context,
    required String productId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Product product = Product(
      name: '',
      description: '',
      quantity: 0,
      images: [],
      category: '',
      price: 0,
    );
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/admin/get-product/$productId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          product = Product.fromJson(jsonEncode(jsonDecode(res.body)));
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return product;
  }

  void deleteProduct({
    required BuildContext context,
    required Product product,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/delete-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': product.id,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          onSuccess();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Order>> fetchAllOrders(
      BuildContext context, String branchId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];
    try {
      http.Response res = await http
          .get(Uri.parse('$uri/admin/get-orders?branchId=$branchId'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            orderList.add(
              Order.fromJson(
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
    return orderList;
  }

  Future<Order> getOderDetail(BuildContext context, String orderId) async {
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
      http.Response res = await http.post(
          Uri.parse(
            '$uri/admin/get-order-detail',
          ),
          body: jsonEncode({
            'id': orderId,
          }),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          order = Order.fromJson(res.body);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return order;
  }

  void changeOrderStatus({
    required BuildContext context,
    required int status,
    required Order order,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      LoadingShowAble.showLoading();
      http.Response res = await http.post(
        Uri.parse('$uri/admin/change-order-status'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': order.id,
          'status': status,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: onSuccess,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<Map<String, dynamic>> getEarnings(
      BuildContext context, String branchId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Sales> sales = [];
    int totalEarning = 0;
    try {
      http.Response res = await http
          .get(Uri.parse('$uri/admin/analytics?branchId=$branchId'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });

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
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return {
      'sales': sales,
      'totalEarnings': totalEarning,
    };
  }

  // MANAGE BRANCH

  void addBranch({
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

      http.Response res = await http.post(
        Uri.parse('$uri/admin/add-branch'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: branch.toJson(),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Đã thêm chi nhánh thành công!');
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void editBranch({
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
        id: userProvider.user.id,
        name: branchName,
        email: email,
        password: userProvider.user.password,
        address: address,
        type: "branch",
        token: userProvider.user.token,
        cart: userProvider.user.cart,
        publicKey: userProvider.user.publicKey,
        privateKey: userProvider.user.privateKey,
      );

      http.Response res = await http.patch(
        Uri.parse('$uri/admin/edit-branch/$branchId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: user.toJson(),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Đã sửa chi nhánh thành công!');
          Navigator.of(context).pop(true);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get all the branches
  Future<List<User>> fetchAllBranches(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<User> branchList = [];
    try {
      http.Response res =
          await http.get(Uri.parse('$uri/admin/get-branches'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': userProvider.user.token,
      });

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            branchList.add(
              User.fromJson(
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
    return branchList;
  }

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
      http.Response res = await http.get(
        Uri.parse('$uri/admin/get-branch/$branchId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          branch = User.fromJson(jsonEncode(jsonDecode(res.body)));
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    return branch;
  }

  void deleteBranch({
    required BuildContext context,
    required User branch,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/admin/delete-branch'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': branch.id,
        }),
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          onSuccess();
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
