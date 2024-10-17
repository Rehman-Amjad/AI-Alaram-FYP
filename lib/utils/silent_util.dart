import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mute/flutter_mute.dart';

class SilentUtil {
  static Future<void> setSilentMode(BuildContext context) async {
    try {
      bool isAccessGranted =
          await FlutterMute.isNotificationPolicyAccessGranted;

      if (!isAccessGranted) {
        await FlutterMute.openNotificationPolicySettings();
      } else {
        await FlutterMute.setRingerMode(RingerMode.Silent);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silent Mode Activated"),
          backgroundColor: Colors.green,
        ),
      );
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Access is not granted!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> setNormalMode(BuildContext context) async {
    try {
      bool isAccessGranted =
      await FlutterMute.isNotificationPolicyAccessGranted;

      if (!isAccessGranted) {
        await FlutterMute.openNotificationPolicySettings();
      } else {
        await FlutterMute.setRingerMode(RingerMode.Normal);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Normal Mode Activated"),
          backgroundColor: Colors.green,
        ),
      );
    } on PlatformException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Access is not granted!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
