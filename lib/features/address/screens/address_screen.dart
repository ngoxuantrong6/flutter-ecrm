import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/constants/utils.dart';
import 'package:flutter_ecrm/features/address/services/address_services.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_ecrm/common/widgets/searchable_picker_sheet.dart';
import 'package:flutter_ecrm/models/province.dart';

class AddressScreen extends StatefulWidget {
  static const String routeName = '/address';
  final String totalAmount;
  const AddressScreen({
    Key? key,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  List<Province> _provinces = [];
  Province? _selectedProvince;
  Ward? _selectedWard;
  final _addressFormKey = GlobalKey<FormState>();

  String addressToBeUsed = "";
  List<PaymentItem> paymentItems = [];
  final AddressServices addressServices = AddressServices();

  String selectedPaymentMethod = 'online'; // Mặc định là thanh toán trực tuyến

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    paymentItems.add(
      PaymentItem(
        amount: widget.totalAmount,
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

  Future<void> _loadProvinces() async {
    final raw = await rootBundle.loadString('assets/data/provinces.json');
    final List<dynamic> json = jsonDecode(raw);
    setState(() {
      _provinces = json.map((p) {
        final wards = (p['wards'] as List<dynamic>)
            .map((w) => Ward(
                  code: (w['ward_code'] as num).toInt(),
                  name: w['name'] as String,
                ))
            .toList();
        return Province(
          code: (p['province_code'] as num).toInt(),
          name: p['name'] as String,
          wards: wards,
        );
      }).toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
  }

  void updateAddress() {
    if (_addressFormKey.currentState!.validate() && _selectedProvince != null && _selectedWard != null) {
      setState(() {
        addressToBeUsed =
        '${addressController.text}, ${_selectedWard!.name}, ${_selectedProvince!.name} - ${phoneNumberController.text}';
      });
    } else {
      setState(() {
        addressToBeUsed = ""; // Reset nếu form không hợp lệ
      });
    }
  }

  void _showProvinceSheet() {
    showSearchablePickerSheet(
      context: context,
      title: 'Chọn Tỉnh / Thành phố',
      items: _provinces
          .map((p) => PickerItem(id: p.code, name: p.name))
          .toList(),
      selectedId: _selectedProvince?.code,
      onSelected: (item) {
        setState(() {
          _selectedProvince = _provinces.firstWhere((p) => p.code == item.id);
          _selectedWard = null; // reset ward when province changes
        });
        updateAddress();
      },
    );
  }

  void _showWardSheet() {
    if (_selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn Tỉnh / Thành phố trước')),
      );
      return;
    }
    showSearchablePickerSheet(
      context: context,
      title: 'Chọn Phường / Xã',
      items: _selectedProvince!.wards
          .map((w) => PickerItem(id: w.code, name: w.name))
          .toList(),
      selectedId: _selectedWard?.code,
      onSelected: (item) {
        setState(() {
          _selectedWard = _selectedProvince!.wards
              .firstWhere((w) => w.code == item.id);
        });
        updateAddress();
      },
    );
  }

  void onApplePayResult(res) {
    if (addressToBeUsed.isEmpty) {
      showSnackBar(context, 'Vui lòng nhập hoặc chọn địa chỉ!');
      return;
    }
    if (Provider.of<UserProvider>(context, listen: false).user.address.isEmpty) {
      addressServices.saveUserAddress(context: context, address: addressToBeUsed);
    }
    addressServices.placeOrder(
      context: context,
      address: addressToBeUsed,
      totalSum: double.parse(widget.totalAmount),
      paymentMethod: 'online',
    );
  }

  void onGooglePayResult(res) {
    if (addressToBeUsed.isEmpty) {
      showSnackBar(context, 'Vui lòng nhập hoặc chọn địa chỉ!');
      return;
    }
    if (Provider.of<UserProvider>(context, listen: false).user.address.isEmpty) {
      addressServices.saveUserAddress(context: context, address: addressToBeUsed);
    }
    addressServices.placeOrder(
      context: context,
      address: addressToBeUsed,
      totalSum: double.parse(widget.totalAmount),
      paymentMethod: 'online',
    );
  }

  void onCodPressed() {
    if (addressToBeUsed.isEmpty) {
      showSnackBar(context, 'Vui lòng nhập hoặc chọn địa chỉ!');
      return;
    }
    if (Provider.of<UserProvider>(context, listen: false).user.address.isEmpty) {
      addressServices.saveUserAddress(context: context, address: addressToBeUsed);
    }
    addressServices.placeOrder(
      context: context,
      address: addressToBeUsed,
      totalSum: double.parse(widget.totalAmount),
      paymentMethod: 'cod',
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
            'Đặt hàng', // Thêm tiêu đề giống AddressBuyNowScreen
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Đổi thành padding 16.0 giống AddressBuyNowScreen
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
                        borderRadius: BorderRadius.circular(8), // Thêm borderRadius giống AddressBuyNowScreen
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
                    // ── Province selector ──────────────────────────────
                    _LocationSelector(
                      label: 'Tỉnh / Thành phố',
                      value: _selectedProvince?.name,
                      placeholder: 'Chọn Tỉnh / Thành phố',
                      onTap: _showProvinceSheet,
                    ),
                    const SizedBox(height: 10),

                    // ── Ward selector ──────────────────────────────────
                    _LocationSelector(
                      label: 'Phường / Xã',
                      value: _selectedWard?.name,
                      placeholder: 'Chọn Phường / Xã',
                      onTap: _showWardSheet,
                    ),
                    const SizedBox(height: 10),

                    // ── Address ────────────────────────────────────────
                    CustomTextField(
                      controller: addressController,
                      hintText: 'Địa chỉ chi tiết',
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
                      onPaymentResult: onApplePayResult,
                      paymentItems: paymentItems,
                      margin: const EdgeInsets.only(top: 15),
                      height: 50,
                      onPressed: () => payPressed(address),
                    ),
                    const SizedBox(height: 10),
                    GooglePayButton(
                      onPressed: () => payPressed(address),
                      paymentConfigurationAsset: 'gpay.json',
                      onPaymentResult: onGooglePayResult,
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
                    primary: Colors.black,
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

// ─── Location Selector ────────────────────────────────────────────────────────

class _LocationSelector extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  const _LocationSelector({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value! : placeholder,
                style: TextStyle(
                  fontSize: 16,
                  color: hasValue ? Colors.black87 : Colors.black38,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}