import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter_ecrm/features/admin/services/branch_services.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/fetch_branch_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product';
  const EditProductScreen({Key? key, required this.product}) : super(key: key);
  final Product product;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final BranchServices branchServices = BranchServices();
  final AdminServices adminServices = AdminServices();

  String category = 'Điện thoại';
  List<String> images = [];
  String branchId = '';
  final _editProductFormKey = GlobalKey<FormState>();
  int activeIndex = 0;
  User? user;
  List<User> branches = [];
  User? currentBranch;

  @override
  void initState() {
    user = Provider.of<UserProvider>(context, listen: false).user;
    images = widget.product.images;
    productNameController.text = widget.product.name;
    descriptionController.text = widget.product.description;
    priceController.text = widget.product.price.toString();
    quantityController.text = widget.product.quantity.toString();
    category = widget.product.category;
    branchId = widget.product.branchId ?? "";
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Provider.of<FetchBranchProvider>(context, listen: false).setListBranch();
      branches =
          Provider.of<FetchBranchProvider>(context, listen: false).listBranch;
      for (var branch in branches) {
        if (branch.id == branchId) {
          currentBranch = branch;
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    productNameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  List<String> productCategories = [
    'Điện thoại',
    'Đồ thiết yếu',
    'Đồ gia dụng',
    'Sách',
    'Thời trang'
  ];

  void editProduct() {
    if (_editProductFormKey.currentState!.validate() && images.isNotEmpty) {
      if (user?.type == "admin") {
        adminServices.editProduct(
          context: context,
          productId: widget.product.id!,
          name: productNameController.text,
          description: descriptionController.text,
          price: int.parse(priceController.text),
          quantity: int.parse(quantityController.text),
          category: category,
          images: images,
          branchId: currentBranch!.id,
        );
      } else {
        branchServices.editProduct(
          context: context,
          productId: widget.product.id!,
          name: productNameController.text,
          description: descriptionController.text,
          price: int.parse(priceController.text),
          quantity: int.parse(quantityController.text),
          category: category,
          images: images,
          branchId: branchId,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fetchBranchProvider = context.watch<FetchBranchProvider>();
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
            'Sửa sản phẩm',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _editProductFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CarouselSlider(
                      items: images.map(
                        (i) {
                          return Builder(
                            builder: (BuildContext context) =>
                                CachedNetworkImage(
                              imageUrl: i,
                              fit: BoxFit.cover,
                              height: 200,
                            ),
                          );
                        },
                      ).toList(),
                      options: CarouselOptions(
                        viewportFraction: 1,
                        height: 200,
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
                        count: images.length,
                        effect: const WormEffect(
                          dotWidth: 8,
                          dotHeight: 8,
                          activeDotColor: GlobalVariables.primaryColor,
                          dotColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: productNameController,
                  hintText: 'Tên sản phẩm',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: descriptionController,
                  hintText: 'Chi tiết',
                  maxLines: 7,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: priceController,
                  hintText: 'Giá',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: quantityController,
                  hintText: 'Số lượng',
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButton(
                    value: category,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: productCategories.map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newVal) {
                      setState(() {
                        category = newVal!;
                      });
                    },
                  ),
                ),
                if (user?.type == "admin") ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButton(
                      value: currentBranch,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: fetchBranchProvider.listBranch.map((User item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        );
                      }).toList(),
                      onChanged: (User? newVal) {
                        // fetchBranchProvider.setBranch(newVal!);
                        setState(() {
                          currentBranch = newVal;
                        });
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Sửa',
                  onTap: editProduct,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
