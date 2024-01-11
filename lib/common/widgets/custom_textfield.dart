import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool? passwordField;
  final bool? isNotSamePass;
  final onTextChanged;
  final AutovalidateMode? autovalidateMode;
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
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _invisible = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: widget.autovalidateMode,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.passwordField == true ? _invisible : false,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: const OutlineInputBorder(
            borderSide: BorderSide(
          color: Colors.black38,
        )),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
          color: Colors.black38,
        )),
        suffixIcon: widget.passwordField == true
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _invisible = !_invisible;
                  });
                },
                child: _invisible == true
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
              )
            : null,
      ),
      onChanged: widget.onTextChanged,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Nhập ${widget.hintText} của bạn';
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
