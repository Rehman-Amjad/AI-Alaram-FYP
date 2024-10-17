import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constant/color.dart';
import '../../../services/auth_services.dart';
import '../../../services/db_services.dart';
import '../../../widget/animation/food_loading.dart';
import '../../../widget/button/simple_button.dart';
import '../../../widget/textfield/custom_text_field.dart';
import '../../homescreen/home_screen.dart';

class SignUp extends StatefulWidget {
  final VoidCallback? function;
  const SignUp({
    Key? key,
    this.function,
  }) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool scroll = false;
  bool toMany = false;
  final _formKey = GlobalKey<FormState>();
  String? password, email, name;
  File? image;
  Future getImage() async {
    var pickedimage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 30);
    if (pickedimage != null) {
      image = File(pickedimage.path);
      print(image);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return scroll
        ? const Scaffold(body: Center(child: FoodLoading()))
        : Scaffold(
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have account ?'),
                TextButton(
                  onPressed: this.widget.function,
                  child: Text(
                    'Sign In',
                    style: TextStyle(color: themeColor),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
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
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 31,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.white,
                      backgroundImage: image != null
                          ? FileImage(image!)
                          : const AssetImage('assets/profile.png')
                              as ImageProvider,
                      child: image == null
                          ? Stack(children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor:
                                      const Color.fromARGB(240, 0, 0, 0),
                                  child: InkWell(
                                    onTap: () {
                                      getImage();
                                    },
                                    child: const Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ])
                          : null,
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
                              name = val;
                            },
                            validation: (value) => value!.isEmpty
                                ? 'This field is required'
                                : null,
                            hintText: 'Full Name',
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          CustomTextField(
                            onChanged: (val) {
                              email = val;
                            },
                            keyBoardType: TextInputType.emailAddress,
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
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
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
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 21,
                    ),
                    SimpleButton(
                      color: themeColor,
                      onTap: () async {
                        if (_formKey.currentState!.validate() &&
                            image != null) {
                          try {
                            setState(() {
                              scroll = true;
                            });

                            final result = await AuthServices()
                                .createUserWithEmailAndPassword(
                              email!,
                              password!,
                            );
                            if (result != null) {
                              String? imageURL = image != null
                                  ? await DatabaseServices().uploadProfilePic(
                                      image!, await AuthServices().getUid())
                                  : null;
                              print(imageURL);
                              await DatabaseServices().createUser(
                                name!,
                                email!,
                                password!,
                                imageURL ?? null,
                              );
                              Navigator.pushAndRemoveUntil(context,
                                  MaterialPageRoute(builder: (context) {
                                return HomeScreen();
                              }), (route) => false);
                              Fluttertoast.showToast(
                                msg: "Registration Successful",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              setState(() {
                                scroll = false;
                              });
                            } else {}
                          } catch (error) {
                            setState(() {
                              scroll = false;
                            });
                          }
                        } else {
                          if (image == null) {
                            Fluttertoast.showToast(
                              msg: "Please Pick Image first",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                        }
                      },
                      title: 'Register',
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  bool showPassword = false;
}
