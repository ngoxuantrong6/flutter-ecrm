import 'package:amazon_clone_tutorial/common/widgets/loader.dart';
import 'package:amazon_clone_tutorial/constants/global_variables.dart';
import 'package:amazon_clone_tutorial/features/account/widgets/single_product.dart';
import 'package:amazon_clone_tutorial/features/admin/screens/add_product_screen.dart';
import 'package:amazon_clone_tutorial/features/admin/services/admin_services.dart';
import 'package:amazon_clone_tutorial/models/product.dart';
import 'package:flutter/material.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Product>? products;
  final AdminServices adminServices = AdminServices();

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
  }

  fetchAllProducts() async {
    products = await adminServices.fetchAllProducts(context);
    setState(() {});
  }

  void deleteProduct(Product product, int index) {
    adminServices.deleteProduct(
      context: context,
      product: product,
      onSuccess: () {
        products!.removeAt(index);
        setState(() {});
      },
    );
  }

  void navigateToAddProduct() {
    Navigator.pushNamed(context, AddProductScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return products == null
        ? const Loader()
        : Scaffold(
            body: GridView.builder(
              itemCount: products!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemBuilder: (context, index) {
                final productData = products![index];
                return Column(
                  children: [
                    SizedBox(
                      height: 140,
                      child: SingleProduct(
                        image: productData.images[0],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Text(
                            productData.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (mContext) {
                                return AlertDialog(
                                    insetPadding: const EdgeInsets.all(48),
                                    contentPadding: const EdgeInsets.all(0),
                                    scrollable: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    content: Column(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.only(
                                              top: 20, left: 20, right: 20),
                                          child: Text(
                                            "Are you sure you want to delete ${productData.name}?",
                                            textAlign: TextAlign.center,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        Container(
                                          height: 40,
                                          margin:
                                              const EdgeInsets.only(top: 20),
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                    flex: 5,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        deleteProduct(
                                                            productData, index);
                                                      },
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        child: const Center(
                                                          child: Text(
                                                            "Agree",
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                                Container(
                                                  width: 1,
                                                  color: Colors.black,
                                                  height: 39,
                                                ),
                                                Expanded(
                                                    flex: 5,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop(true);
                                                      },
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        child: const Center(
                                                          child: Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                              ]),
                                        )
                                      ],
                                    ));
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: navigateToAddProduct,
                tooltip: 'Add a Product',
                backgroundColor: GlobalVariables.primaryColor),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
