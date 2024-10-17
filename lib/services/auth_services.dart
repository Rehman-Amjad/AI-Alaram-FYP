import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widget/button/toast.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference userReference =
      FirebaseFirestore.instance.collection('Users');

  //create user with email and password
  Future createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      return user;
    } catch (e) {
      print(e.toString());
      print("error");
      return null;
    }
  }

  @override
  Future<bool> changePassword(
      {String? oldPassword, String? email, String? newPassword}) async {
    User? userr = _auth.currentUser;
    bool? success;
    final credential =
        EmailAuthProvider.credential(email: email!, password: oldPassword!);
    try {
      UserCredential ans = await userr!
          .reauthenticateWithCredential(credential)
          .catchError((error) {
        showToasterror(error.toString());
      });
      // UserCredential authResult = await userr!.reauthenticateWithCredential(
      //   EmailAuthProvider.credential(
      //     email: email!,
      //     password: oldPassword!,
      //   ),
      // );
      await ans.user!.updatePassword(newPassword!);
      showToasterror('Password Updated Successfully');
      showToasterror('Login Again To Continue');
      success = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToasterror('No user found');
      } else if (e.code == 'wrong-password') {
        showToasterror('Wrong password');
      } else {
        showToasterror(e.code);
      }
      success = false;
    }
    return success != null ? success! : false;
  }

  //Sign in user with existing email and password
  Future signInUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      return user;
    } catch (e) {
      print(e);
      print('error');
      return null;
    }
  }

  String? getNumber() {
    return _auth.currentUser?.phoneNumber;
  }

  Future signUpUsingPhoneNumber(
      String phoneNumber, dynamic onSent, dynamic onFailed) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: onFailed,
        codeSent: onSent,
        codeAutoRetrievalTimeout: (String verificationID) {},
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      print('we have an error');
    }
  }

  Future verifyPhoneNumber(String smsCode, String verificationId) async {
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);
      print('dffzxcxzc');
      final user = await _auth.signInWithCredential(phoneAuthCredential);
      print(user);
      return user;
    } catch (e) {
      print(e);
      print('We have an error here');
      return null;
    }
  }

  getUid() {
    return _auth.currentUser!.uid;
  }

  //get user
  bool userLoggedIn() {
    if (_auth.currentUser != null) {
      return true;
    } else {
      return false;
    }
  }

  //get email
  getEmail() {
    return _auth.currentUser!.email;
  }

  //logOut
  logOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}
