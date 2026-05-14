import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/common/widgets/searchable_picker_sheet.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/admin/screens/manage_branch_screen.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter_ecrm/models/province.dart';

class AddBranchScreen extends StatefulWidget {
  static const String routeName = '/add-branch';
  const AddBranchScreen({Key? key, required this.addBranchArguments})
      : super(key: key);
  final AddBranchArguments addBranchArguments;

  @override
  State<AddBranchScreen> createState() => _AddBranchScreenState();
}

class _AddBranchScreenState extends State<AddBranchScreen> {
  final AdminServices adminServices = AdminServices();
  final _addBranchFormKey = GlobalKey<FormState>();

  List<Province> _provinces = [];
  Province? _selectedProvince;
  Ward? _selectedWard;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
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

  void addBranch() {
    if (_addBranchFormKey.currentState!.validate()) {
      adminServices.addBranch(
        context: context,
        branchName: widget.addBranchArguments.branchNameController.text,
        address: widget.addBranchArguments.addressController.text,
        email: widget.addBranchArguments.emailController.text,
        password: widget.addBranchArguments.passwordController.text,
        provinceId: _selectedProvince?.code,
        wardId: _selectedWard?.code,
      );
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            'Thêm chi nhánh',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _addBranchFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CustomTextField(
                  controller: widget.addBranchArguments.branchNameController,
                  hintText: 'Tên chi nhánh',
                ),
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

                CustomTextField(
                  controller: widget.addBranchArguments.addressController,
                  hintText: 'Địa chỉ chi tiết',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: widget.addBranchArguments.emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: widget.addBranchArguments.passwordController,
                  hintText: 'Mật khẩu',
                  passwordField: true,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Thêm',
                  onTap: addBranch,
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
