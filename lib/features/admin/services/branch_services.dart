import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_ecrm/Model/ChatModel.dart';
import 'package:flutter_ecrm/Model/MessageModel.dart';
import 'package:flutter_ecrm/common/widgets/loading_show_able.dart';
import 'package:flutter_ecrm/constants/error_handling.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/admin/models/sales.dart';
import 'package:flutter_ecrm/models/branch.dart';
import 'package:flutter_ecrm/models/order.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter_ecrm/providers/add_product_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BranchServices {
  Future<void> sellProduct({
    required BuildContext context,
    required String name,
    required String description,
    required int price,
    required int quantity,
    required String category,
    required List<XFile> images,
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
      );

      http.Response res = await http.post(
        Uri.parse('$uri/branch/add-product'),
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
        Uri.parse('$uri/branch/edit-product/$productId'),
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
          await http.get(Uri.parse('$uri/branch/get-products'), headers: {
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
        Uri.parse('$uri/branch/get-product/$productId'),
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
        Uri.parse('$uri/branch/delete-product'),
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

  Future<List<Order>> fetchAllOrders(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Order> orderList = [];
    try {
      http.Response res =
          await http.get(Uri.parse('$uri/branch/get-orders'), headers: {
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
            '$uri/branch/get-order-detail',
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
        Uri.parse('$uri/branch/change-order-status'),
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

  Future<Map<String, dynamic>> getEarnings(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Sales> sales = [];
    int totalEarning = 0;
    try {
      http.Response res =
          await http.get(Uri.parse('$uri/branch/analytics'), headers: {
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

  Future<List<MessageModel>> getMessages({
    required BuildContext context,
    required String chatUserId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<MessageModel> messageList = [];
    try {
      http.Response res = await http.get(
          Uri.parse('$uri/branch/message/get-message/$chatUserId'),
          headers: {
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
    String? messageEncryptForMe,
    String? messageEncryptForReveiver,
    XFile? image,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var messageModel = MessageModel(
        id: "",
        senderId: "",
        receiverId: "",
        messageEncryptForMe: "",
        messageEncryptForReveiver: "",
        createdAt: 0);

    try {
      LoadingShowAble.showLoading();
      final cloudinary = CloudinaryPublic('denz4r8iw', 'mr3ntizn');
      String? imageUrl;

      if (image != null) {
        CloudinaryResponse cloudRes = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path,
              folder: messageEncryptForReveiver ?? ""),
        );
        imageUrl = cloudRes.secureUrl;
      }

      http.Response res = await http.post(
        Uri.parse('$uri/branch/message/send-message/$receiverId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: json.encode({
          'messageEncryptForMe': messageEncryptForMe,
          'messageEncryptForReveiver': messageEncryptForReveiver,
          'image': imageUrl,
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

  Future<List<ChatModel>> getConversations({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<ChatModel> conversationList = [];
    try {
      http.Response res =
          await http.get(Uri.parse('$uri/branch/conversation/list'), headers: {
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
