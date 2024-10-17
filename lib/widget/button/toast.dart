import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToasterror(String label) {
  Fluttertoast.showToast(
      msg: label,
      textColor: Colors.white,
      gravity: ToastGravity.CENTER,
      backgroundColor: const Color.fromARGB(255, 0, 0, 0));
}
