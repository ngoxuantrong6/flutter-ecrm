import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/services/account_services.dart';
import 'package:flutter_ecrm/features/account/widgets/single_product.dart';
import 'package:flutter_ecrm/features/order_details/screens/order_details.dart';
import 'package:flutter_ecrm/models/order.dart';
import 'package:flutter/material.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class MyOrdersScreen extends StatefulWidget {
  static const String routeName = '/my-orders';
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Order>? orders;
  final AccountServices accountServices = AccountServices();

  @override
  void initState() {
    super.initState();
    fetchOrders(); //phương thúc được khởi tạo
  }

  void fetchOrders() async {
    orders = await accountServices.fetchMyOrders(
        context:
            context); // gửi yêu cầu tới server để lấy danh sách đơn hàng hiện tại của người dùng
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: const Text(
            'Đơn hàng của tôi',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: orders == null
          ? const Loader()
          : GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: orders!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final orderData = orders![index];
                return ZoomTapAnimation(
                  onTap: () {
                    Navigator.pushNamed(
                      //chuyển hướng đến màn hình đơn hàng
                      context,
                      OrderDetailScreen.routeName,
                      arguments:
                          orderData, //dữ liệu đơn hàng sẽ được truyền vào màn hình thông qua arguments
                    );
                  },
                  child: SizedBox(
                    child: SingleProduct(
                      image: orderData.products[0].images[0], // sản phẩm sẽ có hình sảnh sản phẩm đầu tiên từ danh sách của đơn hàng
                      order: orderData,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
