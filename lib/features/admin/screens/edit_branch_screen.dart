import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_ecrm/common/widgets/custom_button.dart';
import 'package:flutter_ecrm/common/widgets/custom_textfield.dart';
import 'package:flutter_ecrm/common/widgets/loader.dart';
import 'package:flutter_ecrm/common/widgets/searchable_picker_sheet.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/features/admin/services/admin_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecrm/models/user.dart';
import 'package:flutter_ecrm/models/province.dart';

class EditBranchScreen extends StatefulWidget {
  static const String routeName = '/edit-branch';
  const EditBranchScreen({Key? key, required this.branch}) : super(key: key);
  final User branch;

  @override
  State<EditBranchScreen> createState() => _EditBranchScreenState();
}

class _EditBranchScreenState extends State<EditBranchScreen> {
  final AdminServices adminServices = AdminServices();
  final _editBranchFormKey = GlobalKey<FormState>();
  final TextEditingController branchNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  List<Province> _provinces = [];
  Province? _selectedProvince;
  Ward? _selectedWard;

  @override
  void initState() {
    super.initState();
    branchNameController.text = widget.branch.name;
    addressController.text = widget.branch.address;
    emailController.text = widget.branch.email;

    _loadProvinces().then((_) {
      if (widget.branch.provinceId != null) {
        final match = _provinces.where((p) => p.code == widget.branch.provinceId);
        if (match.isNotEmpty) {
          setState(() {
            _selectedProvince = match.first;
            if (widget.branch.wardId != null) {
              final wMatch = _selectedProvince!.wards
                  .where((w) => w.code == widget.branch.wardId);
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
    branchNameController.dispose();
    addressController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> editBranch() async {
    if (_editBranchFormKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        await adminServices.editBranch(
          context: context,
          branchName: branchNameController.text,
          address: addressController.text,
          email: emailController.text,
          branchId: widget.branch.id,
          password: widget.branch.password,
          publicKey: widget.branch.publicKey,
          privateKey: widget.branch.privateKey,
          provinceId: _selectedProvince?.code,
          wardId: _selectedWard?.code,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sửa chi nhánh thành công!')),
        );
        Navigator.pop(context, true); // Quay lại màn hình trước
      } catch (e) {
        debugPrint('Error editing branch: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi sửa chi nhánh: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
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
            'Sửa chi nhánh',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Loader()
          : SingleChildScrollView(
              child: Form(
                key: _editBranchFormKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: branchNameController,
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
                        controller: addressController,
                        hintText: 'Địa chỉ chi tiết',
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        controller: emailController,
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Sửa',
                        onTap: editBranch,
                      ),
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
