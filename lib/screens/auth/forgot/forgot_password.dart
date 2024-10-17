import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../constant/color.dart';
import '../../../widget/textfield/custom_text_field.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String? email;
  Future resetPassword() async {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => const Center(
              child: CircularProgressIndicator(
                color: themeColor,
              ),
            ));

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email!);
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      //   return SplashScreen();
      // }));
      Navigator.pop(context);
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "Password Reset Mail Sent",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: themeColor,
          textColor: Colors.white,
          fontSize: 16.0);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: "${e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: themeColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text('Reset Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(31),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Receive an Email to Reset Password',
              style: TextStyle(fontSize: 31, color: themeColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 21,
            ),
            CustomTextField(
              hintText: 'Receiving Email',
              onChanged: (val) {
                email = val;
              },
              keyBoardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 21,
            ),
            InkWell(
              onTap: () {
                if (email == null) {
                  Fluttertoast.showToast(
                      msg: "Email is required to recover Password",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                } else {
                  resetPassword();
                }
              },
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: themeColor,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
