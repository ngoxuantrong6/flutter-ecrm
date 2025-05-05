import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool? passwordField;
  final bool? isNotSamePass;
  final Function(String)? onTextChanged;
  final AutovalidateMode? autovalidateMode;
  final String? Function(String?)? validator;
  final double hintFontSize; // Thêm thuộc tính để điều chỉnh phông chữ hintText

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.passwordField,
    this.isNotSamePass,
    this.onTextChanged,
    this.autovalidateMode,
    this.validator,
    this.hintFontSize = 14.0, // Mặc định là 14
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isInvisible = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.passwordField == true ? _isInvisible : false,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: widget.hintFontSize), // Áp dụng kích thước phông chữ
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black38),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black38),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black87),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        suffixIcon: widget.passwordField == true
            ? IconButton(
          icon: Icon(
            _isInvisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isInvisible = !_isInvisible;
            });
          },
        )
            : null,
      ),
      onChanged: widget.onTextChanged,
      validator: (value) {
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập ${widget.hintText.toLowerCase()}';
        }
        if (widget.isNotSamePass == true) {
          return 'Mật khẩu xác nhận không khớp với mật khẩu mới';
        }
        return null;
      },
      maxLines: widget.maxLines,
    );
  }
}