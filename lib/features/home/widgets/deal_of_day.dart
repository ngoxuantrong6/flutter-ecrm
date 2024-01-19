import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/home/services/home_services.dart';
import 'package:flutter_ecrm/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DealOfDay extends StatefulWidget {
  const DealOfDay({Key? key}) : super(key: key);

  @override
  State<DealOfDay> createState() => _DealOfDayState();
}

class _DealOfDayState extends State<DealOfDay> {
  Product? product;
  final HomeServices homeServices = HomeServices();

  @override
  void initState() {
    super.initState();
    fetchDealOfDay();
  }

  void fetchDealOfDay() async {
    product = await homeServices.fetchDealOfDay(context: context);
    setState(() {});
  }

  void navigateToDetailScreen() {
    Navigator.pushNamed(
      context,
      ProductDetailScreen.routeName,
      arguments: product?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return product == null
        ? const Loader()
        : product!.name.isEmpty
            ? const SizedBox()
            : GestureDetector(
                onTap: navigateToDetailScreen,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 10, top: 15),
                      child: const Text(
                        'Deal HOT nhất trong ngày',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CachedNetworkImage(
                      imageUrl: product!.images[0],
                      height: 235,
                      fit: BoxFit.fitHeight,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 15),
                      alignment: Alignment.topLeft,
                      child: Text(
                        '${formatPrice(product!.price)} đ',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Container(
                    //   alignment: Alignment.topLeft,
                    //   padding:
                    //       const EdgeInsets.only(left: 15, top: 5, right: 40),
                    //   child: const Text(
                    //     'Rivaan',
                    //     maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: product!.images
                            .map(
                              (e) => CachedNetworkImage(
                                imageUrl: e,
                                fit: BoxFit.fitWidth,
                                width: 100,
                                height: 100,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     vertical: 15,
                    //   ).copyWith(left: 15),
                    //   alignment: Alignment.topLeft,
                    //   child: const Text(
                    //     'See all deals',
                    //     style: TextStyle(
                    //       color: GlobalVariables.primaryColor,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
  }
}
