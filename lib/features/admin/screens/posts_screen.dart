import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
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

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    setState(() {
      isLoading = true;
    });
    try {
      await fetchAllProducts();
      if (user?.type == "admin") {
        await fetchAllBranches();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddProductProvider>().setCategory('Điện thoại');
        context.read<AddProductProvider>().setImages([]);
      });
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAllBranches() async {
    try {
      branches = await adminServices.fetchAllBranches(context);
      GlobalVariables.branches = branches ?? [];
      Provider.of<FetchBranchProvider>(context, listen: false).setListBranch();
    } catch (e) {
      debugPrint('Error fetching branches: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi nhánh: $e')),
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> fetchAllProducts() async {
    try {
      if (user?.type == "admin") {
        await fetchBranchProducts(branchId: "");
      } else {
        products = await branchServices.fetchAllProducts(context);
      }
    } catch (e) {
      debugPrint('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải sản phẩm: $e')),
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> fetchBranchProducts({required String branchId}) async {
    setState(() {
      products = null;
    });
    try {
      products = await adminServices.fetchBranchProducts(
        context: context,
        branchId: branchId,
      );
    } catch (e) {
      debugPrint('Error fetching branch products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải sản phẩm chi nhánh: $e')),
      );
    }
    if (mounted) setState(() {});
  }

  void deleteProduct(Product product, int index) {
    if (user?.type == "admin") {
      adminServices.deleteProduct(
        context: context,
        product: product,
        onSuccess: () {
          if (mounted) {
            products!.removeAt(index);
            setState(() {});
          }
        },
      );
    } else {
      branchServices.deleteProduct(
        context: context,
        product: product,
        onSuccess: () {
          if (mounted) {
            products!.removeAt(index);
            setState(() {});
          }
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
      if (value != null && mounted) {
        fetchAllProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fetchBranchProvider = context.watch<FetchBranchProvider>();
    return isLoading
        ? const Loader()
        : products == null
            ? const Center(child: Text('Không có sản phẩm nào'))
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
                            items:
                                fetchBranchProvider.listBranch.map((User item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item.name),
                              );
                            }).toList(),
                            onChanged: (User? newVal) {
                              if (newVal != null) {
                                fetchBranchProvider.setBranch(newVal);
                                fetchBranchProducts(
                                    branchId: fetchBranchProvider.branch.id);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Thêm padding xung quanh GridView
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: products!.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing:
                                10.0, // Khoảng cách ngang giữa các item
                            mainAxisSpacing:
                                10.0, // Khoảng cách dọc giữa các item
                            childAspectRatio:
                                0.75, // Tỷ lệ chiều cao/chiều rộng của item
                          ),
                          itemBuilder: (context, index) {
                            final productData = products![index];
                            final imageUrl = productData.images.isNotEmpty
                                ? productData.images[0]
                                : 'https://via.placeholder.com/150'; // Ảnh mặc định nếu không có ảnh

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ZoomTapAnimation(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      EditProductScreen.routeName,
                                      arguments: productData,
                                    ).then((value) {
                                      if (value != null && mounted) {
                                        fetchBranchProvider.setBranch(
                                            fetchBranchProvider.listBranch[0]);
                                        fetchAllProducts();
                                      }
                                    });
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                        maxHeight:
                                            120), // Giới hạn chiều cao ảnh
                                    child: SingleProduct(
                                      image: imageUrl,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    height: 5), // Khoảng cách giữa ảnh và tên
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          productData.name,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines:
                                              1, // Giới hạn tên sản phẩm 1 dòng
                                          style: const TextStyle(
                                            fontSize:
                                                14, // Điều chỉnh kích thước font
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20, // Kích thước icon hợp lý
                                      ),
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
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: navigateToAddProduct,
                  tooltip: 'Thêm sản phẩm',
                  backgroundColor: GlobalVariables.primaryColor,
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
              );
  }
}
