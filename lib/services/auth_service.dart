import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../pages/home_page.dart';
import '../pages/login_page_2.dart';
import '../utils/static_variable.dart';

class AuthService {
  Future<bool> checkIfGymAlreadyRegistered(String gymName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('gyms')
          .where('name', isEqualTo: gymName)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Selected gym does not have user with this email",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
  }

  Future<void> signup(
      {required String gymName,
      required String email,
      required String password,
      required BuildContext context}) async {
    try {
      var gymRegistered = await checkIfGymAlreadyRegistered(gymName);

      if (!gymRegistered) {
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        addGymToDb(userCredential.user?.uid, gymName, email);
        await Future.delayed(
          const Duration(
            seconds: 1,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MyHomePage(),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "A gym with this name is already registered",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> signin(
      {required String email,
      required String password,
      required BuildContext context,
      required String gymName}) async {
    try {
      var userInGym = await checkIfUserIsGymMember(email, gymName);

      if (userInGym) {
        StaticVariable.gymIdVariable = await getGymId(gymName);

        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        await Future.delayed(
          const Duration(seconds: 1),
        );
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => MyHomePage(),
            ),
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Selected gym does not have user with this email",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } on FirebaseAuthException catch (e) {
      print('e.code: ${e.code}');
      print('e: $e');
      String message = '';
      if (e.code == 'channel-error') {
        message = 'No user found for that email.';
        var snackBar = SnackBar(content: Text('No user found for that email.'));
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
        var snackBar =
            SnackBar(content: Text('Wrong password provided for that user.'));
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LoginPage2(),
      ),
    );

    StaticVariable.gymIdVariable = '';
  }

  Future<void> addGymToDb(String? userId, String gymName, String email) async {
    try {
      await FirebaseFirestore.instance.collection("gyms").doc(userId).set({
        "name": gymName,
        "email": email,
        "gymId": userId,
      });

      StaticVariable.gymIdVariable = await getGymId(gymName);
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<bool> checkIfUserIsGymMember(String email, String gym) async {
    try {
      var gymId = await getGymId(gym);
      QuerySnapshot membersQuery = await FirebaseFirestore.instance
          .collection('members')
          .where('email', isEqualTo: email)
          .where('gymId', isEqualTo: gymId)
          .limit(1)
          .get();

      QuerySnapshot coachesQuery = await FirebaseFirestore.instance
          .collection('coaches')
          .where('email', isEqualTo: email)
          .where('gymId', isEqualTo: gymId)
          .limit(1)
          .get();

      QuerySnapshot gymsQuery = await FirebaseFirestore.instance
          .collection('gyms')
          .where('email', isEqualTo: email)
          .where('gymId', isEqualTo: gymId)
          .limit(1)
          .get();

      return membersQuery.docs.isNotEmpty ||
          coachesQuery.docs.isNotEmpty ||
          gymsQuery.docs.isNotEmpty;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Selected gym does not have user with this email",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
  }

  Future<String?> getGymId(String gymName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('gyms')
          .where('name', isEqualTo: gymName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        return doc['gymId'];
      } else {
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
