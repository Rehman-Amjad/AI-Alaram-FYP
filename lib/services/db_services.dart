import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart' as storage;

import 'auth_services.dart';

class DatabaseServices {
  //reference for users
  final CollectionReference userReference =
      FirebaseFirestore.instance.collection('Users');
  final CollectionReference ordersReference =
      FirebaseFirestore.instance.collection('orders');

  final CollectionReference menuReference =
      FirebaseFirestore.instance.collection('Menu');

  //add Driver
  Future createUser(
    String fullName,
    String email,
    String password,
    var imageURL,
  ) async {
    try {
      await userReference.doc(AuthServices().getUid()).set(
        {
          'Full Name': fullName,
          'Email': email,
          'Profile Url': imageURL,
          'imageURL': imageURL,
          'isAdmin': false,
          'anyReservation': false,
          'Password': password,
          'Uid': AuthServices().getUid(),
          'User type': 'Customer',
          'dateTimeOfReservation': ''
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String> uploadToDatabase(File? pickedImage) async {
    try {
      print("Uid is ${FirebaseAuth.instance.currentUser!.uid}");
      if (pickedImage != null) {
        storage.Reference reference = storage.FirebaseStorage.instance
            .ref("Profile_Image/${FirebaseAuth.instance.currentUser!.uid}");

        // Wait for the upload to complete
        final uploadTask = reference.putFile(pickedImage);
        final storageSnapshot = await uploadTask.whenComplete(() => null);
        // Now get the download URL
        final downloadUrl = await storageSnapshot.ref.getDownloadURL();
        print("DownloadUrl is $downloadUrl");
        return downloadUrl;
      }
      throw Exception('No compressed image provided');
    } catch (e) {
      // Log and handle errors
      print('Error uploading to Firebase Storage: $e');
      throw e;
    }
  }

  // Future userQuantity(
  //   String documentId,
  //   num quantity,
  // ) async {
  //   return await menuReference.doc(documentId).update({
  //     'User Quantity': FieldValue.arrayUnion([
  //       {
  //         AuthServices().getUid(): quantity,
  //       }
  //     ]),
  //   });
  // }

  //get Menu Items
  Stream<QuerySnapshot> getMenuItems(String uid) {
    return userReference.doc(uid).collection('myMenu').snapshots();
  }

  //upload image/video to storage
  Future addFileTStorage(File file) async {
    final storage = FirebaseStorage.instance;
    var snapshot = await storage.ref().child(file.path).putFile(file);
    String url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Future<String> uploadProfilePic(File image, String uid) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference firebaseStorageRef =
        storage.ref().child('user/profilePicture/$uid');
    UploadTask uploadTask = firebaseStorageRef.putFile(image);
    String imageUrl = await uploadTask.then((p0) => p0.ref.getDownloadURL());
    return imageUrl;
  }

  //pick file from gallery
  Future pickImage() async {
    final _picker = ImagePicker();
    var image;
    image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    return image;
  }

  //Users streams
  Stream<QuerySnapshot> getUserStream() {
    return userReference.snapshots();
  }

  Future adminHINT(
      String uid, String adminUid, String useradmin, bool hint) async {
    return await userReference
        .doc(uid)
        .collection('myChats')
        .doc(adminUid)
        .update({
      useradmin: hint,
    });
  }

  Future anyReservation(String uid, bool hint, DateTime reservation) async {
    return await userReference
        .doc(uid)
        .update({'anyReservation': hint, 'dateTimeOfReservation': reservation});
  }

  Future updateTableNumber(String uid, String adminUid, String hint) async {
    userReference.doc(uid).collection('myChats').doc(adminUid).update({
      'tableNumber': hint,
    });
    userReference.doc(adminUid).collection('myAllOrders').doc(uid).update({
      'tableNumber': hint,
    });
    return await userReference
        .doc(uid)
        .collection('activeOrders')
        .doc('myOrders')
        .update({
      'tableNumber': hint,
    });
  }

  //get User Stream
  Stream<DocumentSnapshot> getUserData() {
    return userReference.doc(AuthServices().getUid()).snapshots();
  }

  //get User Stream
  Stream<DocumentSnapshot> getRestaurantData(String uid) {
    return userReference.doc(uid).snapshots();
  }

  //check user if exist
  Future checkUser(String uid) {
    return userReference.doc(uid).get();
  }

  Future updateOrderRating(
      String ResId, String docID, bool isRated, double totalRating) async {
    await userReference
        .doc(ResId)
        .collection('myAllOrders')
        .doc(docID)
        .update({'isRated': isRated, 'totalRating': totalRating});
  }

  Future<void> addRating(String ResId, double totalRating) async {
    final DocumentReference<Map<String, dynamic>> restaurantReference =
        FirebaseFirestore.instance
            .collection("Users")
            .doc(ResId)
            .collection("myRatings")
            .doc("myRatings");

    try {
      final DocumentSnapshot<Map<String, dynamic>> restaurantSnapshot =
          await restaurantReference.get();

      if (restaurantSnapshot.exists) {
        print("Document exists. Updating ratings...");

        // Document exists, update the list
        final List<dynamic> existingRatings =
            restaurantSnapshot.data()?["allRatings"] ?? [];

        existingRatings.add(totalRating);
        print(existingRatings);
        await restaurantReference.update({
          "allRatings": FieldValue.arrayUnion([totalRating])
        });

        print("Ratings updated successfully!");
      } else {
        print(
            "Document does not exist. Creating document with initial rating...");

        // Document does not exist, create it with the initial rating
        await restaurantReference.set({
          "allRatings": [totalRating]
        });

        print("Document created with initial rating!");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future updateRatings(String adminUID, String docId, double rating) async {
    await userReference
        .doc(await AuthServices().getUid())
        .collection('myAllOrders')
        .doc(docId)
        .update({'totalRating': rating, 'isRated': true});
    var doc = await userReference
        .doc(adminUID)
        .collection('myRatings')
        .doc('myRatings')
        .get();
    if (doc.exists == false) {
      await userReference
          .doc(adminUID)
          .collection('myRatings')
          .doc('myRatings')
          .set({
        'allRatings': FieldValue.arrayUnion([rating]),
      }, SetOptions(merge: true));
    } else {
      var allRatings = doc.get('allRatings');
      allRatings.add(rating);
      userReference
          .doc(adminUID)
          .collection('myRatings')
          .doc('myRatings')
          .update({
        'allRatings': allRatings,
      });
    }
  }

  Future deleteUserReservation(String uid, String docID) async {
    return await userReference
        .doc(uid)
        .collection('myReservations')
        .doc(docID)
        .delete();
  }

  Future myReservations(
      String date,
      String time,
      String name,
      String uid,
      String restaurantUID,
      int numberOfPeople,
      DateTime dateTime,
      String resName) async {
    return await userReference
        .doc(restaurantUID)
        .collection('myReservations')
        .doc()
        .set({
      'myReservationDate': date,
      'myReservationTime': time,
      'userName': name,
      'dateTime': dateTime,
      'numberOfPeople': numberOfPeople,
      'result': 'Pending',
      'restaurantUID': restaurantUID,
      "userUid": uid,
      'tableNumber': '',
      "restaurantName": resName
    }, SetOptions(merge: true)).then((value) {
      print("Set Successfully");
    });
  }

  Future totalQRScans(String uid) async {
    return await userReference
        .doc(uid)
        .collection('totalQRScans')
        .doc('myScans')
        .set({
      'allScans': [],
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
      'lastMon': 0,
      'lastTue': 0,
      'lastWed': 0,
      'lastThu': 0,
      'lastFri': 0,
      'lastSat': 0,
      'lastSun': 0
    }, SetOptions(merge: true));
  }

  Future updateMyQRScans(String day, String uid) async {
    var doc = await userReference
        .doc(uid)
        .collection('totalQRScans')
        .doc('myScans')
        .get();
    print(doc[day]);

    await userReference
        .doc(uid)
        .collection('totalQRScans')
        .doc('myScans')
        .update({
      day: doc[day] + 1,
    });
    await userReference
        .doc(uid)
        .collection('totalQRScans')
        .doc('myScans')
        .update({
      'allScans': FieldValue.arrayUnion([Timestamp.now()]),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> restaurantRefrence() {
    return FirebaseFirestore.instance
        .collection('Users')
        .where('User type', isEqualTo: 'Restaurant')
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> myOrdersRefrence() async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(await AuthServices().getUid())
        .collection('activeOrders')
        .doc('myOrders')
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> myCategoriesRefrence(
      String id) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .collection('myCategories')
        .doc('myCategories')
        .get();
  }

  Future saveNotificationToResaurant(
      String docId, String notiType, String notiInfo, String imageURL) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(docId)
        .collection('myNotifications')
        .doc()
        .set({
      'notificationType': notiType,
      'userID': await AuthServices().getUid(),
      'restaurantID': docId,
      'imageURL': imageURL,
      'timeStamp': DateTime.now(),
      'notificationInfo': notiInfo
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> myMenuRefrence(String id) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(id)
        .collection('myMenu')
        .get();
  }

  Future sendOrderToRestaurant({
    bool isRated = false,
    String paymentMethod = 'Payment Pending',
    required String restaurantUID,
    required String tableNumber,
    required Timestamp timestamp,
    required String totalPrice,
    List<String>? transactions,
    dynamic totalRating,
    bool activeSession = true,
    required List orderItemsQuantity,
    required String userUID,
  }) async {
    final data = {
      'isRated': isRated,
      'paymentMethod': paymentMethod,
      'restaurantUID': restaurantUID,
      'tableNumber': tableNumber,
      'transactions': transactions ?? [],
      'timestamp': timestamp,
      'activeSession': activeSession,
      'totalPrice': totalPrice,
      'totalRating': totalRating,
      'orderItems&Quantity': orderItemsQuantity,
      'userUID': userUID,
    };
    QuerySnapshot<Object?> querySnapshot = await ordersReference
        .where(
          Filter.and(
            Filter('userUID', isEqualTo: userUID),
            Filter('activeSession', isEqualTo: true),
          ),
        )
        .get();

    // Check if any matching documents exist
    if (querySnapshot.docs.isNotEmpty) {
      print('Document has data matching the conditions!');
      final docID = querySnapshot.docs[0].id;
      final items = querySnapshot.docs[0]['orderItems&Quantity'];
      final tableNumber = querySnapshot.docs[0]['tableNumber'];

      orderItemsQuantity.addAll(items);

      data['orderItems&Quantity'] = orderItemsQuantity;
      data['tableNumber'] = tableNumber;
      data['transactions'] = querySnapshot.docs[0]['transactions'];
      if (transactions != null) {
        data['transactions'].addAll(transactions);
      }

      ordersReference.doc(docID).update(data);
    } else {
      print('Document does not have data matching the conditions.');
      ordersReference.add(data);
    }
  }

  Future updateOrder({
    required String orderID,
    required Map<String, dynamic> data,
  }) async {
    ordersReference.doc(orderID).update(data);
  }

  Future confirmMyOrder(
    List orders,
    String uid,
    String restaurantUID,
    double price,
    String paymentMethod,
    String transactionID,
    String currency,
    String tableNumber,
    String resUid,
    bool paid,
  ) async {
    await userReference.doc(restaurantUID).collection('myAllOrders').doc().set({
      'orderItems&Quantity': orders,
      'paymentMethod': paymentMethod,
      'userUID': uid,
      'transactionID': transactionID,
      "totalPrice": price,
      'timeStamp': DateTime.now(),
      'tableNumber': tableNumber,
      "currency": currency,
      'orderCompleted': 'Order received',
      "isRated": false,
      'totalRating': null,
      "paid": paid,
    });
    await userReference
        .doc(await AuthServices().getUid())
        .collection('myAllOrders')
        .doc()
        .set({
      'orderItems&Quantity': orders,
      'paymentMethod': paymentMethod,
      'userUID': uid,
      'transactionID': transactionID,
      "totalPrice": price,
      'restaurantUID': restaurantUID,
      'timeStamp': DateTime.now(),
      "currency": currency,
      'tableNumber': tableNumber,
      'totalRating': null,
      'isRated': false,
      'orderCompleted': 'Order received',
    });
  }

  //check if the user completed the form
  /// Check If Document Exists
  Future<bool> checkIfDocExists(String docId) async {
    try {
      var doc = await userReference.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }
}
