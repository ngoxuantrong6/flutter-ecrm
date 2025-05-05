import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/address/services/address_services.dart';
import 'package:flutter_ecrm/models/product.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';

class AddressBuyNowScreen extends StatefulWidget {
  static const String routeName = '/address-buy-now';
  final Product product;
  const AddressBuyNowScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<AddressBuyNowScreen> createState() => _AddressBuyNowScreenState();
}

class _AddressBuyNowScreenState extends State<AddressBuyNowScreen> {
  final TextEditingController flatBuildingController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final _addressFormKey = GlobalKey<FormState>();

  String addressToBeUsed = "";
  List<PaymentItem> paymentItems = [];
  final AddressServices addressServices = AddressServices();

  String selectedPaymentMethod = 'online';

  @override
  void initState() {
    super.initState();
    paymentItems.add(
      PaymentItem(
        amount: widget.product.price.toString(),
        label: 'Total Amount',
        status: PaymentItemStatus.final_price,
      ),
    );

    // Tự động gán địa chỉ đã lưu nếu có
    final userAddress = Provider.of<UserProvider>(context, listen: false).user.address;
    if (userAddress.isNotEmpty) {
      addressToBeUsed = userAddress;
    }
  }

  @override
  void dispose() {
    super.dispose();
    flatBuildingController.dispose();
    areaController.dispose();
    phoneNumberController.dispose();
    cityController.dispose();
  }

  void updateAddress() {
    if (_addressFormKey.currentState!.validate()) {
      setState(() {
        addressToBeUsed =
        '${flatBuildingController.text}, ${areaController.text}, ${cityController.text} - ${phoneNumberController.text}';
      });
    } else {
      setState(() {
        addressToBeUsed = ""; // Reset nếu form không hợp lệ
      });
    }
  }

  void onPaymentResult(res) {
    if (addressToBeUsed.isEmpty) {
      showSnackBar(context, 'Vui lòng nhập hoặc chọn địa chỉ!');
      return;
    }
    if (widget.product.branchId == null) {
      showSnackBar(context, 'Sản phẩm không có thông tin chi nhánh. Vui lòng liên hệ hỗ trợ!');
      return;
    }
    if (Provider.of<UserProvider>(context, listen: false).user.address.isEmpty) {
      addressServices.saveUserAddress(context: context, address: addressToBeUsed);
    }
    addressServices.buyNow(
      context: context,
      id: widget.product.id!,
      address: addressToBeUsed,
      paymentMethod: 'online',
      branchId: widget.product.branchId,
    );
  }

  void onCodPressed() {
    if (addressToBeUsed.isEmpty) {
      showSnackBar(context, 'Vui lòng nhập hoặc chọn địa chỉ!');
      return;
    }
    if (widget.product.branchId == null) {
      showSnackBar(context, 'Sản phẩm không có thông tin chi nhánh. Vui lòng liên hệ hỗ trợ!');
      return;
    }
    if (Provider.of<UserProvider>(context, listen: false).user.address.isEmpty) {
      addressServices.saveUserAddress(context: context, address: addressToBeUsed);
    }
    addressServices.buyNow(
      context: context,
      id: widget.product.id!,
      address: addressToBeUsed,
      paymentMethod: 'cod',
      branchId: widget.product.branchId,
    );
  }

  void payPressed(String addressFromProvider) {
    if (addressToBeUsed.isEmpty && addressFromProvider.isEmpty) {
      showSnackBar(context, 'Vui lòng nhập hoặc chọn địa chỉ!');
      return;
    }
    if (addressToBeUsed.isEmpty && addressFromProvider.isNotEmpty) {
      addressToBeUsed = addressFromProvider;
    }
  }

  @override
  Widget build(BuildContext context) {
    var address = context.watch<UserProvider>().user.address;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: const Text(
            'Đặt hàng',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (address.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Địa chỉ đã lưu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          address,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'HOẶC',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              const Text(
                'Thông tin giao hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Form(
                key: _addressFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: flatBuildingController,
                      hintText: 'Căn hộ, Số nhà, Tòa nhà',
                      hintFontSize: 14,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập thông tin này';
                        }
                        return null;
                      },
                      onTextChanged: (_) => updateAddress(),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: areaController,
                      hintText: 'Đường, Khu vực',
                      hintFontSize: 14,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập thông tin này';
                        }
                        return null;
                      },
                      onTextChanged: (_) => updateAddress(),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: phoneNumberController,
                      hintText: 'SĐT',
                      hintFontSize: 14,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                      onTextChanged: (_) => updateAddress(),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: cityController,
                      hintText: 'Tỉnh/Thành phố',
                      hintFontSize: 14,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập thông tin này';
                        }
                        return null;
                      },
                      onTextChanged: (_) => updateAddress(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const Text(
                'Chọn phương thức thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: 'online',
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Thanh toán trực tuyến',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'cod',
                        groupValue: selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Thanh toán khi nhận hàng (COD)',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (selectedPaymentMethod == 'online' && addressToBeUsed.isNotEmpty)
                Column(
                  children: [
                    ApplePayButton(
                      width: double.infinity,
                      style: ApplePayButtonStyle.whiteOutline,
                      type: ApplePayButtonType.buy,
                      paymentConfigurationAsset: 'applepay.json',
                      onPaymentResult: onPaymentResult,
                      paymentItems: paymentItems,
                      margin: const EdgeInsets.only(top: 15),
                      height: 50,
                      onPressed: () => payPressed(address),
                    ),
                    const SizedBox(height: 10),
                    GooglePayButton(
                      onPressed: () => payPressed(address),
                      paymentConfigurationAsset: 'gpay.json',
                      onPaymentResult: onPaymentResult,
                      paymentItems: paymentItems,
                      height: 50,
                      type: GooglePayButtonType.buy,
                      margin: const EdgeInsets.only(top: 15),
                      loadingIndicator: const Center(child: Loader()),
                    ),
                  ],
                ),
              if (selectedPaymentMethod == 'cod' && addressToBeUsed.isNotEmpty)
                ElevatedButton(
                  onPressed: onCodPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đặt hàng (Thanh toán khi nhận)',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              if (addressToBeUsed.isEmpty)
                const Text(
                  'Vui lòng nhập hoặc chọn địa chỉ để tiếp tục thanh toán!',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }
}