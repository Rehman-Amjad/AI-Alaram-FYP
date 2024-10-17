import 'package:flutter/material.dart';

class SimpleButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? color, titleColor, borderColor;
  final double? borderRadius, titleFontSize, width, height;

  SimpleButton({
    Key? key,
    required this.onTap,
    required this.title,
    this.color,
    this.height,
    this.width,
    this.titleFontSize,
    this.titleColor,
    this.borderRadius,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height ?? 44,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: color ?? const Color(0xff4D4D4D),
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          border: Border.all(color: borderColor ?? Colors.white, width: 1),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize ?? 20,
              color: titleColor ?? Colors.white,
              // fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
