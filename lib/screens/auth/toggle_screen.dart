import 'package:ai_alarm/screens/auth/signup/signup.dart';
import 'package:flutter/material.dart';

import 'login/login_screen.dart';

class Toggle extends StatefulWidget {
  const Toggle({Key? key}) : super(key: key);

  @override
  _ToggleState createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> {
  bool showSignIn = true;
  toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showSignIn
        ? SignIn(
            function: () {
              toggleView();
            },
          )
        : SignUp(
            function: () {
              toggleView();
            },
          );
  }
}
