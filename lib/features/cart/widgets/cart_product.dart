import 'package:flutter/material.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/cart/services/cart_services.dart';
import 'package:flutter_ecrm/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_ecrm/features/product_details/services/product_details_services.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class CartProduct extends StatefulWidget {
  final int index;
  const CartProduct({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  State<CartProduct> createState() => _CartProductState();
}

class _CartProductState extends State<CartProduct> {
  final ProductDetailsServices productDetailsServices =
      ProductDetailsServices();
  final CartServices cartServices = CartServices();

  void increaseQuantity(Product product) {
    productDetailsServices.addToCart(
      context: context,
      product: product,
      fromProductDetailScreen: false,
    );
  }

  void decreaseQuantity(Product product) {
    cartServices.removeFromCart(
      context: context,
      product: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productCart = context.watch<UserProvider>().user.cart[widget.index];
    final product = Product.fromMap(productCart['product']);
    final quantity = productCart['quantity'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼 Hình ảnh sản phẩm (Giới hạn kích thước để tránh lỗi tràn)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isUrl(product.images[0])
                ? CachedNetworkImage(
                    imageUrl: product.images[0],
                    fit: BoxFit.cover,
                    width: 90, // ✅ Giới hạn chiều rộng
                    height: 90, // ✅ Giới hạn chiều cao
                  )
                : imageFromBase64String(
                    product.images[0],
                    fit: BoxFit.cover,
                    width: 90,
                    height: 90,
                  ),
          ),

          const SizedBox(width: 10), // Khoảng cách giữa ảnh & nội dung

          // 📝 Phần thông tin sản phẩm
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sản phẩm (Chống lỗi tràn bằng `maxLines`)
                Text(
                  product.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // ✅ Giới hạn 2 dòng để tránh tràn
                ),
                const SizedBox(height: 5),

                // Giá sản phẩm
                Text(
                  '${formatPrice(product.price)} đ',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),

                // Thông tin Free Ship & Kho hàng
                const Text("Đủ điều kiện FREE Ship",
                    style: TextStyle(fontSize: 13, color: Colors.green)),
                const SizedBox(height: 5),
                const Text(
                  "Còn trong kho",
                  style: TextStyle(
                      fontSize: 13, color: GlobalVariables.primaryColor),
                ),
              ],
            ),
          ),

          // 📦 Bộ đếm số lượng sản phẩm
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => decreaseQuantity(product),
                      child: Container(
                        width: 35,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            right:
                                BorderSide(color: Colors.black12, width: 1.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.remove,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Container(
                      width: 35,
                      height: 32,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    InkWell(
                      onTap: () => increaseQuantity(product),
                      child: Container(
                        width: 35,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.black12, width: 1.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
