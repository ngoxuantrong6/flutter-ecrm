import 'package:flutter_ecrm/common/widgets/popup_notification_custom.dart';
import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/widgets/single_product.dart';
import 'package:flutter_ecrm/features/admin/screens/add_product_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/edit_product_screen.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter_ecrm/providers/add_product_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AddProductArguments {
  final TextEditingController productNameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final String category;
  final List<XFile> images;

  AddProductArguments({
    required this.productNameController,
    required this.descriptionController,
    required this.priceController,
    required this.quantityController,
    required this.category,
    required this.images,
  });
}

class PostsScreen extends StatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<Product>? products;
  final AdminServices adminServices = AdminServices();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAllProducts();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<AddProductProvider>().setCategory('Điện thoại');
      context.read<AddProductProvider>().setImages([]);
    });
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
    Navigator.pushNamed(
      context,
      AddProductScreen.routeName,
      arguments: AddProductArguments(
        productNameController: productNameController,
        descriptionController: descriptionController,
        priceController: priceController,
        quantityController: quantityController,
        category: context.read<AddProductProvider>().category,
        images: context.read<AddProductProvider>().images,
      ),
    ).then((value) {
      if (value != null) {
        fetchAllProducts();
      }
    });
  }

  // @override
  // void dispose() {
  //   context.read<AddProductProvider>().setCategory('Điện thoại');
  //   context.read<AddProductProvider>().setImages([]);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return products == null
        ? const Loader()
        : Scaffold(
            body: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: products!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              itemBuilder: (context, index) {
                final productData = products![index];
                return Column(
                  children: [
                    ZoomTapAnimation(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          EditProductScreen.routeName,
                          arguments: productData,
                        ).then((value) {
                          if (value != null) {
                            fetchAllProducts();
                          }
                        });
                      },
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 140),
                        child: SingleProduct(
                          image: productData.images[0],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              productData.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            PopupNotificationCustom.showMessgae(
                              context: context,
                              title: 'XÓA SẢN PHẨM',
                              message:
                                  'Bạn có chắc muốn xóa ${productData.name}?',
                              pressButtonLeft: () =>
                                  deleteProduct(productData, index),
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
