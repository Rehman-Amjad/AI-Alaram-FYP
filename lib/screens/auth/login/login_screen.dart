import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../constant/color.dart';
import '../../../services/auth_services.dart';
import '../../../widget/button/simple_button.dart';
import '../../../widget/textfield/custom_text_field.dart';
import '../../homescreen/home_screen.dart';
import '../forgot/forgot_password.dart';

class SignIn extends StatefulWidget {
  final VoidCallback? function;
  const SignIn({
    Key? key,
    this.function,
  }) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool scroll = false;
  String? email, password;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return scroll
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: themeColor,
              ),
            ),
          )
        : Scaffold(
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have and account ?'),
                TextButton(
                  onPressed: this.widget.function,
                  child: Text(
                    'Register',
                    style: TextStyle(color: themeColor),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.12,
                left: MediaQuery.of(context).size.height * 0.07,
                right: MediaQuery.of(context).size.height * 0.07,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/applogo.png',
                      width: 80,
                      height: 80,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                    ),
                    Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 31,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            onChanged: (val) {
                              email = val;
                            },
                            keyBoardType: TextInputType.emailAddress,
                            // obsureText: false,
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required';
                              } else if (!RegExp(
                                      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                  .hasMatch(value)) {
                                return 'Enter a valid email address';
                              }
                              return null; // Return null for valid input
                            },
                            hintText: 'Email',
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          CustomTextField(
                            onChanged: (val) {
                              password = val;
                            },
                            prefixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              child: showPassword == false
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                            ),
                            obsureText: showPassword,
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required';
                              } else if (value.length < 6) {
                                return 'Password should be at least 6 characters';
                              }
                              return null; // Return null for valid input
                            },
                            hintText: 'Password',
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    TextButton(
                      child: Text(
                        'Forgot Password ?',
                        style: TextStyle(
                          fontSize: 11,
                          color: themeColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ForgotPassword();
                        }));
                      },
                    ),
                    SizedBox(
                      height: 21,
                    ),
                    SimpleButton(
                      color: themeColor,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            setState(() {
                              scroll = true;
                            });

                            var result = await AuthServices()
                                .signInUserWithEmailAndPassword(
                                    email!, password!);
                            print('Here');
                            if (result != null) {
                              // Get.offAll(BottomNavBar());
                              Navigator.pushAndRemoveUntil(context,
                                  MaterialPageRoute(builder: (context) {
                                return HomeScreen();
                              }), (route) => false);
                            } else {
                              setState(() {
                                scroll = false;
                              });
                              Fluttertoast.showToast(
                                  msg:
                                      "Invalid Credentials Or Users Don't Exists",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          } catch (e) {
                            setState(() {
                              scroll = false;
                            });
                            Fluttertoast.showToast(
                                msg: "Error while Signing in",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        }
                      },
                      title: 'Sign In',
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  bool showPassword = false;
}
