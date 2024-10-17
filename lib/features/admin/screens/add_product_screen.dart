import 'dart:io';

import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/admin/screens/posts_screen.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter_ecrm/features/admin/services/branch_services.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/providers/add_product_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/providers/fetch_branch_provider.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AddProductScreen extends StatefulWidget {
  static const String routeName = '/add-product';
  const AddProductScreen({Key? key, required this.addProductArguments})
      : super(key: key);
  final AddProductArguments addProductArguments;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final BranchServices branchServices = BranchServices();
  final AdminServices adminServices = AdminServices();
  User? user;
  final _addProductFormKey = GlobalKey<FormState>();
  int activeIndex = 0;

  List<String> productCategories = [
    'Điện thoại',
    'Đồ thiết yếu',
    'Đồ gia dụng',
    'Sách',
    'Thời trang'
  ];

  void sellProduct() {
    if (_addProductFormKey.currentState!.validate() &&
        context.read<AddProductProvider>().images.isNotEmpty) {
      if (user?.type == "admin") {
        adminServices
            .sellProduct(
          context: context,
          name: widget.addProductArguments.productNameController.text,
          description: widget.addProductArguments.descriptionController.text,
          price: int.parse(widget.addProductArguments.priceController.text),
          quantity:
              int.parse(widget.addProductArguments.quantityController.text),
          category: context.read<AddProductProvider>().category,
          images: context.read<AddProductProvider>().images,
          branchId: context.read<FetchBranchProvider>().branch.id,
        )
            .then((value) {
          widget.addProductArguments.productNameController.clear();
          widget.addProductArguments.descriptionController.clear();
          widget.addProductArguments.priceController.clear();
          widget.addProductArguments.quantityController.clear();
        });
      } else {
        branchServices
            .sellProduct(
          context: context,
          name: widget.addProductArguments.productNameController.text,
          description: widget.addProductArguments.descriptionController.text,
          price: int.parse(widget.addProductArguments.priceController.text),
          quantity:
              int.parse(widget.addProductArguments.quantityController.text),
          category: context.read<AddProductProvider>().category,
          images: context.read<AddProductProvider>().images,
        )
            .then((value) {
          widget.addProductArguments.productNameController.clear();
          widget.addProductArguments.descriptionController.clear();
          widget.addProductArguments.priceController.clear();
          widget.addProductArguments.quantityController.clear();
        });
      }
    }
  }

  @override
  void initState() {
    user = Provider.of<UserProvider>(context, listen: false).user;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Provider.of<FetchBranchProvider>(context, listen: false).setListBranch();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final addProductProvider = context.watch<AddProductProvider>();
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
            'Thêm sản phẩm',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _addProductFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                addProductProvider.images.isNotEmpty
                    ? Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          CarouselSlider(
                            items: addProductProvider.images.map(
                              (i) {
                                return Builder(
                                  builder: (BuildContext context) => Image.file(
                                    File(i.path),
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
                              count: widget.addProductArguments.images.length,
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
                    : ZoomTapAnimation(
                        onTap: () async {
                          var res = await selectImages2();
                          addProductProvider.setImages(res);
                        },
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(10),
                          dashPattern: const [10, 4],
                          strokeCap: StrokeCap.round,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.folder_open,
                                  size: 40,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'Chọn hình ảnh sản phẩm',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: widget.addProductArguments.productNameController,
                  hintText: 'Tên sản phẩm',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: widget.addProductArguments.descriptionController,
                  hintText: 'Chi tiết',
                  maxLines: 7,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: widget.addProductArguments.priceController,
                  hintText: 'Giá',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: widget.addProductArguments.quantityController,
                  hintText: 'Số lượng',
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: DropdownButton(
                    value: addProductProvider.category,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: productCategories.map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newVal) {
                      addProductProvider.setCategory(newVal!);
                      // setState(() {
                      //   widget.addProductArguments.category = newVal!;
                      //   print(
                      //       "categoryyyyyyy ${widget.addProductArguments.category}");
                      // });
                    },
                  ),
                ),
                if (user?.type == "admin") ...[
                  const SizedBox(height: 10),
                  SizedBox(
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
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Bán',
                  onTap: sellProduct,
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
