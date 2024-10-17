import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final dynamic onChanged;
  final String? hintText;
  final dynamic validation;
  final dynamic prefixIcon;
  final dynamic maxLines;
  final bool initVal;
  final dynamic minLines;
  final dynamic obsureText;
  final String? initialValue;
  final dynamic keyBoardType;
  final dynamic controller;

  CustomTextField(
      {Key? key,
      this.controller,
      this.initVal = false,
      this.keyBoardType,
      this.obsureText,
      this.hintText,
      this.prefixIcon,
      this.initialValue,
      this.onChanged,
      this.maxLines,
      this.minLines,
      this.validation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // Add elevation for a subtle lift
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        autovalidateMode:
            AutovalidateMode.onUserInteraction, // Validate as the user types
        validator: validation,
        obscureText: obsureText ?? false,
        onChanged: onChanged,
        controller: controller,
        maxLines: maxLines ?? 1,
        keyboardType: keyBoardType ?? TextInputType.text,
        decoration: InputDecoration(
          label: RichText(
            text: TextSpan(
              text: hintText,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.circular(15),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent, width: 0),
            borderRadius: BorderRadius.circular(15),
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          suffixIcon: prefixIcon,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
