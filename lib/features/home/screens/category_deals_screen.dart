import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/widgets/single_product.dart';
import 'package:flutter_ecrm/features/home/services/home_services.dart';
import 'package:flutter_ecrm/features/product_details/screens/product_details_screen.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/fetch_branch_provider.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CategoryDealsScreen extends StatefulWidget {
  static const String routeName = '/category-deals';
  final String category;
  const CategoryDealsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryDealsScreen> createState() => _CategoryDealsScreenState();
}

class _CategoryDealsScreenState extends State<CategoryDealsScreen> {
  List<Product>? productList;
  final HomeServices homeServices = HomeServices();

  @override
  void initState() {
    super.initState();
    fetchCategoryProducts(branchId: "");
    // Trì hoãn việc gọi setListBranch() cho đến khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FetchBranchProvider>(context, listen: false).setListBranch();
    });
  }

  fetchCategoryProducts({required String branchId}) async {
    productList = null;
    productList = await homeServices.fetchCategoryProducts(
      context: context,
      category: widget.category,
      branchId: branchId,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fetchBranchProvider = context.watch<FetchBranchProvider>();
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: GlobalVariables.appBarGradient,
                ),
              ),
              title: Text(
                widget.category,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                alignment: Alignment.topLeft,
                child: Text(
                  'Tiếp tục mua sắm với ${widget.category}',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButton(
                    value: fetchBranchProvider.branch,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: fetchBranchProvider.listBranch.map((User item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (User? newVal) {
                      fetchBranchProvider.setBranch(newVal!);
                      fetchCategoryProducts(
                          branchId: fetchBranchProvider.branch.id);
                      // setState(() {
                      //   widget.addProductArguments.category = newVal!;
                      //   print(
                      //       "categoryyyyyyy ${widget.addProductArguments.category}");
                      // });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              productList == null
                  ? const Loader()
                  : Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: productList!.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        // gridDelegate:
                        //     const SliverGridDelegateWithFixedCrossAxisCount(
                        //   crossAxisCount: 1,
                        //   childAspectRatio: 1.4,
                        //   mainAxisSpacing: 10,
                        // ),
                        itemBuilder: (context, index) {
                          final product = productList![index];
                          return ZoomTapAnimation(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ProductDetailScreen.routeName,
                                arguments: product.id,
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  constraints:
                                      const BoxConstraints(maxHeight: 140),
                                  child: SingleProduct(
                                    image: productList![index].images[0],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
