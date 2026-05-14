import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield_label.dart';
import 'package:flutter_ecrm/common/widgets/searchable_picker_sheet.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/account/services/account_services.dart';
import 'package:flutter_ecrm/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ecrm/models/province.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class UpdateProfileScreen extends StatefulWidget {
  static const String routeName = '/update-profile';
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final AccountServices accountServices = AccountServices();
  final _formKey = GlobalKey<FormState>();

  List<Province> _provinces = [];
  Province? _selectedProvince;
  Ward? _selectedWard;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    userNameController.text = user.name;
    emailController.text = user.email;
    addressController.text = user.address;

    _loadProvinces().then((_) {
      if (user.provinceId != null) {
        final match = _provinces.where((p) => p.code == user.provinceId);
        if (match.isNotEmpty) {
          setState(() {
            _selectedProvince = match.first;
            if (user.wardId != null) {
              final wMatch =
                  _selectedProvince!.wards.where((w) => w.code == user.wardId);
              if (wMatch.isNotEmpty) _selectedWard = wMatch.first;
            }
          });
        }
      }
    });
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
    userNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void updateProfile() {
    if (_formKey.currentState!.validate()) {
      accountServices.updateProfile(
        context: context,
        userName: userNameController.text,
        address: addressController.text,
        provinceId: _selectedProvince?.code,
        wardId: _selectedWard?.code,
      );
    }
  }

  // ─── Show province picker ─────────────────────────────────────────────────

  void _showProvinceSheet() {
    showSearchablePickerSheet(
      context: context,
      title: 'Chọn Tỉnh / Thành phố',
      items:
          _provinces.map((p) => PickerItem(id: p.code, name: p.name)).toList(),
      selectedId: _selectedProvince?.code,
      onSelected: (item) {
        setState(() {
          _selectedProvince = _provinces.firstWhere((p) => p.code == item.id);
          _selectedWard = null; // reset ward when province changes
        });
      },
    );
  }

  // ─── Show ward picker ─────────────────────────────────────────────────────

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
          _selectedWard =
              _selectedProvince!.wards.firstWhere((w) => w.code == item.id);
        });
      },
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
              title: const Text(
                'Thông tin cá nhân',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: userNameController,
                      hintText: 'Tên',
                    ),
                    const SizedBox(height: 10),
                    CustomTextFieldLabel(email: emailController.text),
                    const SizedBox(height: 10),

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
                    ),
                    const SizedBox(height: 50),
                    CustomButton(
                      text: 'Cập nhật',
                      onTap: updateProfile,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
