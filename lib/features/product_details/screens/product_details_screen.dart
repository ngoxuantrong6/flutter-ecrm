import 'package:amazon_clone_tutorial/common/widgets/custom_button.dart';
import 'package:amazon_clone_tutorial/common/widgets/loader.dart';
import 'package:amazon_clone_tutorial/common/widgets/stars.dart';
import 'package:amazon_clone_tutorial/constants/utils.dart';
import 'package:amazon_clone_tutorial/features/product_details/services/product_details_services.dart';
import 'package:amazon_clone_tutorial/providers/user_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:amazon_clone_tutorial/constants/global_variables.dart';
import 'package:amazon_clone_tutorial/features/search/screens/search_screen.dart';
import 'package:amazon_clone_tutorial/models/product.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  static const String routeName = '/product-details';
  final String productId;
  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductDetailsServices productDetailsServices =
      ProductDetailsServices();
  double avgRating = 0;
  double myRating = 0;
  Product? product;

  @override
  void initState() {
    super.initState();
    getProductDetail();
  }

  void getProductDetail() async {
    product = await productDetailsServices.getProductDetail(
        context: context, productId: widget.productId);
    setState(() {});
  }

  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
  }

  void addToCart() {
    productDetailsServices.addToCart(
      context: context,
      product: product!,
      fromProductDetailScreen: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalRating = 0;
    if (product != null) {
      for (int i = 0; i < product!.rating!.length; i++) {
        totalRating += product!.rating![i].rating;
        if (product!.rating![i].userId ==
            Provider.of<UserProvider>(context, listen: false).user.id) {
          myRating = product!.rating![i].rating;
        }
      }

      if (totalRating != 0) {
        avgRating = totalRating / product!.rating!.length;
      }
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  margin: const EdgeInsets.only(left: 15),
                  child: Material(
                    borderRadius: BorderRadius.circular(7),
                    elevation: 1,
                    child: TextFormField(
                      onFieldSubmitted: navigateToSearchScreen,
                      decoration: InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.only(
                              left: 6,
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 23,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        hintText: 'Tìm kiếm',
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.transparent,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: const Icon(Icons.mic, color: Colors.black, size: 25),
              ),
            ],
          ),
        ),
      ),
      body: product == null
          ? const Loader()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOP bán chạy trong ${product!.category}',
                          style: const TextStyle(
                              color: GlobalVariables.primaryColor),
                        ),
                        Stars(
                          rating: avgRating,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 10,
                    ),
                    child: Text(
                      product!.name,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  CarouselSlider(
                    items: product!.images.map(
                      (i) {
                        return Builder(
                          builder: (BuildContext context) => Image.network(
                            i,
                            fit: BoxFit.contain,
                            height: 200,
                          ),
                        );
                      },
                    ).toList(),
                    options: CarouselOptions(
                      viewportFraction: 1,
                      height: 300,
                    ),
                  ),
                  Container(
                    color: Colors.black12,
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: RichText(
                      text: TextSpan(
                        text: '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '${formatPrice(product!.price)} đ',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(product!.description),
                  ),
                  Container(
                    color: Colors.black12,
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomButton(
                      text: 'Mua ngay',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomButton(
                      text: 'Thêm vào giỏ hàng',
                      onTap: addToCart,
                      color: const Color.fromRGBO(254, 216, 19, 1),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.black12,
                    height: 5,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Đánh giá sản phẩm',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: myRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: GlobalVariables.secondaryColor,
                    ),
                    onRatingUpdate: (rating) {
                      productDetailsServices.rateProduct(
                        context: context,
                        product: product!,
                        rating: rating,
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }
}
