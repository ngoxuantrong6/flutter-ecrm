import 'package:flutter_ecrm/common/widgets/popup_notification_custom.dart';
import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/widgets/single_product.dart';
import 'package:flutter_ecrm/features/admin/screens/add_product_screen.dart';
import 'package:flutter_ecrm/features/admin/screens/edit_product_screen.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter_ecrm/features/admin/services/branch_services.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/add_product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/providers/fetch_branch_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
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
  final BranchServices branchServices = BranchServices();
  final AdminServices adminServices = AdminServices();
  User? user;
  List<User>? branches;
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    fetchAllProducts();
    if (user?.type == "admin") {
      fetchAllBranches();
    }
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      context.read<AddProductProvider>().setCategory('Điện thoại');
      context.read<AddProductProvider>().setImages([]);
    });
  }

  fetchAllBranches() async {
    branches = await adminServices.fetchAllBranches(context);
    GlobalVariables.branches = branches ?? [];
    Provider.of<FetchBranchProvider>(context, listen: false).setListBranch();
    setState(() {});
  }

  fetchAllProducts() async {
    if (user?.type == "admin") {
      // products = await adminServices.fetchAllProducts(context);
      fetchBranchProducts(branchId: "");
    } else {
      products = await branchServices.fetchAllProducts(context);
    }
    setState(() {});
  }

  fetchBranchProducts({required String branchId}) async {
    products = null;
    products = await adminServices.fetchBranchProducts(
      context: context,
      branchId: branchId,
    );
    setState(() {});
  }

  void deleteProduct(Product product, int index) {
    if (user?.type == "admin") {
      adminServices.deleteProduct(
        context: context,
        product: product,
        onSuccess: () {
          products!.removeAt(index);
          setState(() {});
        },
      );
    } else {
      branchServices.deleteProduct(
        context: context,
        product: product,
        onSuccess: () {
          products!.removeAt(index);
          setState(() {});
        },
      );
    }
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
    final fetchBranchProvider = context.watch<FetchBranchProvider>();
    return products == null
        ? const Loader()
        : Scaffold(
            body: Column(
              children: [
                if (user?.type == "admin") ...[
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
                          fetchBranchProducts(
                              branchId: fetchBranchProvider.branch.id);
                        },
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: products!.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  fetchBranchProvider.setBranch(
                                      fetchBranchProvider.listBranch[0]);
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
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: navigateToAddProduct,
                tooltip: 'Thêm sản phẩm',
                backgroundColor: GlobalVariables.primaryColor),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
  }
}
