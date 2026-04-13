import 'dart:async';

import 'package:flutter_ecrm/features/chat/screens/IndividualPage.dart';
import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/common/widgets/stars.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/address/screens/address_buy_now_screen.dart';
import 'package:flutter_ecrm/features/product_details/services/product_details_services.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/search/screens/search_screen.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:speech_to_text/speech_recognition_event.dart';

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
  int activeIndex = 0;
  TextEditingController searchTextController = TextEditingController();
  late StreamSubscription<SpeechRecognitionEvent> subscription;
  bool _isListening = false;
  String _text = '';
  String _hintText = 'Tìm kiếm';

  @override
  void initState() {
    // khơi tạo
    super.initState();
    getProductDetail();
  }

  @override
  void dispose() {
    searchTextController.clear();
    super.dispose();
  }

  void getProductDetail() async {
    product = await productDetailsServices.getProductDetail(
        context: context, productId: widget.productId);
    setState(() {});
  }

  void navigateToSearchScreen(String query) {
    Navigator.pushNamed(context, SearchScreen.routeName, arguments: query);
  }

  void navigateToAddressBuyNowScreen(Product product) {
    Navigator.pushNamed(
      context,
      AddressBuyNowScreen.routeName,
      arguments: product,
    );
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
    searchTextController.text = _text;
    double totalRating = 0;
    if (product != null) {
      // kiểm tra xem dữ liệu sản phẩm đã được tải chưa , ban đầu là null , sau khi getProductDetail thì mới có giá trị
      for (int i = 0; i < product!.rating!.length; i++) {
        // duyệt qua rating mảng đánh giá sản phẩm
        totalRating += product!
            .rating![i].rating; // cộng dồn điểm đánh giá tất cả người dùng
        if (product!.rating![i].userId ==
            Provider.of<UserProvider>(context, listen: false).user.id) {
          myRating = product!.rating![i].rating;
        }
      }

      if (totalRating != 0) {
        avgRating = totalRating /
            product!.rating!
                .length; //tính điểm trung bình đánh giá bằng avgRating / số lượng đánh giá
      }
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            // sử dụng để phủ lên toàn bộ khu vực của Appbar
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
                      controller: searchTextController,
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
                        hintText: _hintText,
                        hintStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AvatarGlow(
                animate: _isListening,
                glowColor: Theme.of(context).primaryColor,
                endRadius: 25.0,
                duration: const Duration(milliseconds: 2000),
                repeatPauseDuration: const Duration(milliseconds: 100),
                child: GestureDetector(
                  onTap: _listen,
                  child: Container(
                    color: Colors.transparent,
                    height: 42,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.black, size: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: product == null
          ? const Loader()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Tiêu đề sản phẩm + Xếp hạng
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'TOP bán chạy trong ${product?.category ?? "Danh mục"}',
                              style: const TextStyle(
                                color: GlobalVariables.primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Stars(rating: avgRating),
                        ],
                      ),
                    ),

                    /// Tên sản phẩm
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        product?.name ?? "Không có tên sản phẩm",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    /// Ảnh sản phẩm (Carousel Slider)
                    if (product?.images.isNotEmpty ?? false)
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          CarouselSlider(
                            items: product!.images
                                .map(
                                  (image) => Builder(
                                    builder: (context) => isUrl(image)
                                        ? CachedNetworkImage(
                                            imageUrl: image,
                                            fit: BoxFit.contain,
                                            height: 250,
                                            width: double.infinity,
                                          )
                                        : imageFromBase64String(
                                            image,
                                            fit: BoxFit.contain,
                                            height: 250,
                                            width: double.infinity,
                                          ),
                                  ),
                                )
                                .toList(),
                            options: CarouselOptions(
                              viewportFraction: 1,
                              height: 250,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  activeIndex = index;
                                });
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            child: AnimatedSmoothIndicator(
                              activeIndex: activeIndex,
                              count: product!.images.length,
                              effect: const WormEffect(
                                dotWidth: 8,
                                dotHeight: 8,
                                activeDotColor: GlobalVariables.primaryColor,
                                dotColor: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 250,
                        alignment: Alignment.center,
                        color: Colors.grey[200],
                        child: const Text(
                          "Không có hình ảnh",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),

                    const SizedBox(height: 10),
                    Container(color: Colors.black12, height: 5),

                    /// Giá sản phẩm
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: RichText(
                        text: TextSpan(
                          text: 'Giá: ',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${formatPrice(product!.price)} đ',
                              style: const TextStyle(
                                fontSize: 22,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// Mô tả sản phẩm
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product?.description ?? "Không có mô tả sản phẩm",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    Container(color: Colors.black12, height: 5),

                    /// Nút Mua ngay
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: CustomButton(
                        text: 'Mua ngay',
                        onTap: () => navigateToAddressBuyNowScreen(product!),
                      ),
                    ),

                    /// Nút Thêm vào giỏ hàng
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: CustomButton(
                        text: 'Thêm vào giỏ hàng',
                        onTap: addToCart,
                        color: const Color.fromRGBO(254, 216, 19, 1),
                      ),
                    ),

                    Container(color: Colors.black12, height: 5),

                    /// Đánh giá sản phẩm
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

                    /// Thanh đánh giá
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
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          productDetailsServices
              .getUserById(
            context: context,
            branchId: product!.branchId ?? "",
          )
              .then((receiver) {
            Navigator.pushNamed(
              context,
              IndividualPage.routeName,
              arguments: IndividualPageArguments(
                productDetail: product,
                receiver: receiver,
              ),
            );
          });
        },
        child: Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
    );
  }

  void _listen() {
    GlobalVariables.speechProvider.listen(
        pauseFor: const Duration(seconds: 5),
        // localeId: 'en-us',
        listenFor: const Duration(seconds: 5));
    subscription = GlobalVariables.speechProvider.stream.listen(
      (event) {
        // on listening starts
        if (event.eventType == SpeechRecognitionEventType.statusChangeEvent) {
          _hintText = 'Đang nghe';
          if (mounted) {
            setState(() => _isListening = true);
          }
        }
        // on every change it update
        if (event.eventType ==
            SpeechRecognitionEventType.partialRecognitionEvent) {
          if (mounted) {
            setState(
              () {
                _text = GlobalVariables.speechProvider.lastResult!
                    .recognizedWords; // the textField or Text Widget Will be updated
              },
            );
          }
        }
        //on error
        else if (event.eventType == SpeechRecognitionEventType.errorEvent) {
          ///on error if some error occurs then close the dilog box here . or stop the listner
          print('onError');
        }

        //on done
        else if (event.eventType == SpeechRecognitionEventType.doneEvent) {
          //when the user stop speaking.
          subscription.cancel();
          setState(() => _isListening = false);
          navigateToSearchScreen(_text);
        }
      },
    );
  }
}

class IndividualPageArguments {
  final Product? productDetail;
  final User receiver;

  IndividualPageArguments({
    this.productDetail,
    required this.receiver,
  });
}
