import 'dart:convert';
import 'package:flutter_ecrm/common/widgets/loading_show_able.dart';
import 'package:flutter_ecrm/constants/error_handling.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/order_details/screens/order_details.dart';
import 'package:flutter_ecrm/models/order.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddressServices {
  // Lưu địa chỉ người dùng
  void saveUserAddress({
    required BuildContext context,
    required String address,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print('Saving user address: $address');

    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/save-user-address'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'address': address,
        }),
      );

      print('Save address response status: ${res.statusCode}');
      print('Save address response body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          User user = userProvider.user.copyWith(
            address: jsonDecode(res.body)['address'],
          );
          userProvider.setUserFromModel(user);
          print('Address saved successfully: ${user.address}');
        },
      );
    } catch (e) {
      print('Error saving address: $e');
      showSnackBar(context, e.toString());
    }
  }

  // Cập nhật địa chỉ người dùng
  void updateUserAddress({
    required BuildContext context,
    required String newAddress,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print('Updating user address to: $newAddress');

    try {
      http.Response res = await http.put(
        Uri.parse('$uri/api/update-user-address'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'address': newAddress,
        }),
      );

      print('Update address response status: ${res.statusCode}');
      print('Update address response body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          User user = userProvider.user.copyWith(
            address: jsonDecode(res.body)['address'],
          );
          userProvider.setUserFromModel(user);
          showSnackBar(context, 'Địa chỉ đã được cập nhật!');
          print('Address updated successfully: ${user.address}');
        },
      );
    } catch (e) {
      print('Error updating address: $e');
      showSnackBar(context, e.toString());
    }
  }

  // Lấy danh sách địa chỉ người dùng
  Future<List<String>> getUserAddresses({
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<String> addresses = [];
    print('Fetching user addresses');

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/get-user-addresses'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      print('Get addresses response status: ${res.statusCode}');
      print('Get addresses response body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          final responseData = jsonDecode(res.body);
          if (responseData['addresses'] != null) {
            addresses = List<String>.from(responseData['addresses']);
            print('Addresses fetched: $addresses');
          }
        },
      );
    } catch (e) {
      print('Error fetching addresses: $e');
      showSnackBar(context, e.toString());
    }

    return addresses;
  }

  // Đặt hàng từ giỏ hàng
  void placeOrder({
    required BuildContext context,
    required String address,
    required double totalSum,
    String paymentMethod = 'online',
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print('Placing order - Address: $address, Total: $totalSum, Method: $paymentMethod');

    try {
      LoadingShowAble.showLoading();
      print('Sending order request to $uri/api/order');
      http.Response res = await http.post(
        Uri.parse('$uri/api/order'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'cart': userProvider.user.cart,
          'address': address,
          'totalPrice': totalSum,
          'paymentMethod': paymentMethod,
        }),
      );

      print('Order response status: ${res.statusCode}');
      print('Order response body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            paymentMethod == 'online'
                ? 'Bạn đã đặt hàng và thanh toán thành công!'
                : 'Bạn đã đặt hàng thành công! Vui lòng thanh toán khi nhận hàng.',
          );
          User user = userProvider.user.copyWith(cart: []);
          userProvider.setUserFromModel(user);
          print('Order placed successfully, navigating to OrderDetailScreen');
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            OrderDetailScreen.routeName,
            arguments: Order.fromJson(jsonEncode(jsonDecode(res.body))),
          );
        },
      );
    } catch (e) {
      print('Error placing order: $e');
      showSnackBar(context, e.toString());
    } finally {
      LoadingShowAble.hideLoading();
      print('Loading hidden after order attempt');
    }
  }

  void buyNow({
    required BuildContext context,
    required String id,
    required String address,
    String paymentMethod = 'online',
    String? branchId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print('Buying now - ID: $id, Address: $address, Method: $paymentMethod, Branch: $branchId');

    try {
      LoadingShowAble.showLoading();
      print('Token: ${userProvider.user.token}');
      print('Request URL: $uri/api/buy-now');
      print('Request Body: ${jsonEncode({
        'id': id,
        'address': address,
        'paymentMethod': paymentMethod,
        'branchId': branchId,
      })}');

      http.Response res = await http.post(
        Uri.parse('$uri/api/buy-now'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'id': id,
          'address': address,
          'paymentMethod': paymentMethod,
          'branchId': branchId,
        }),
      );

      print('Response Status: ${res.statusCode}');
      print('Response Body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            paymentMethod == 'online'
                ? 'Bạn đã đặt hàng và thanh toán thành công!'
                : 'Bạn đã đặt hàng thành công! Vui lòng thanh toán khi nhận hàng.',
          );
          print('Buy now successful, navigating to OrderDetailScreen');
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            OrderDetailScreen.routeName,
            arguments: Order.fromJson(jsonEncode(jsonDecode(res.body))),
          );
        },
      );
    } catch (e) {
      print('Error in buyNow: $e');
      showSnackBar(context, e.toString());
    } finally {
      LoadingShowAble.hideLoading();
      print('Loading hidden after buy now attempt');
    }
  }

  // Lấy thông tin đơn hàng
  Future<Order?> getOrderDetails({
    required BuildContext context,
    required String orderId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Order? order;
    print('Fetching order details for ID: $orderId');

    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/order/$orderId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      print('Get order details response status: ${res.statusCode}');
      print('Get order details response body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          order = Order.fromJson(jsonEncode(jsonDecode(res.body)));
          print('Order details fetched: $order');
        },
      );
    } catch (e) {
      print('Error fetching order details: $e');
      showSnackBar(context, e.toString());
    }

    return order;
  }

  // Hủy đơn hàng
  void cancelOrder({
    required BuildContext context,
    required String orderId,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print('Canceling order with ID: $orderId');

    try {
      LoadingShowAble.showLoading();
      http.Response res = await http.post(
        Uri.parse('$uri/api/cancel-order'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: jsonEncode({
          'orderId': orderId,
        }),
      );

      print('Cancel order response status: ${res.statusCode}');
      print('Cancel order response body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Đơn hàng đã được hủy!');
          print('Order canceled successfully');
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      print('Error canceling order: $e');
      showSnackBar(context, e.toString());
    } finally {
      LoadingShowAble.hideLoading();
      print('Loading hidden after cancel attempt');
    }
  }

  // Xóa sản phẩm
  void deleteProduct({
    required BuildContext context,
    required Product product,
    required VoidCallback onSuccess,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print('Deleting product with ID: ${product.id}');

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

      print('Delete product response status: ${res.statusCode}');
      print('Delete product response body: ${res.body}');

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: onSuccess,
      );
    } catch (e) {
      print('Error deleting product: $e');
      showSnackBar(context, e.toString());
    }
  }
}