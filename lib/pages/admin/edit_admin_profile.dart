import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/change_password.dart';

import '../home_page.dart';

class EditAdminProfile extends StatefulWidget {
  const EditAdminProfile({super.key});

  @override
  State<EditAdminProfile> createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isButtonVisible = false;
  final gymNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  var gymName = "";
  var phoneNumber = "";

  bool coach = false;

  @override
  void dispose() {
    gymNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    gymNameController.addListener(() {
      setState(() {
        _isButtonVisible = gymNameController.text.isNotEmpty ||
            phoneController.text.isNotEmpty;
      });
    });

    phoneController.addListener(() {
      setState(() {
        _isButtonVisible = phoneController.text.isNotEmpty ||
            gymNameController.text.isNotEmpty;
      });
    });
  }

  Future<void> fetchData() async {
    try {
      var collection = FirebaseFirestore.instance.collection('gyms');
      var docSnapshot = await collection.doc(userId).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();

        setState(() {
          gymName = data?['name'];
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void Validate(String email) {
    bool isvalid = EmailValidator.validate(email);
    print(isvalid);
  }

  Future<void> updateDb(String? userId) async {
    try {
      if (gymNameController.text.trim() == "") {
        await FirebaseFirestore.instance.collection("gyms").doc(userId).update({
          "phone": phoneController.text.trim(),
        });
      } else if (phoneController.text.trim() == "") {
        await FirebaseFirestore.instance.collection("gyms").doc(userId).update({
          "name": gymNameController.text.trim(),
        });
      } else {
        await FirebaseFirestore.instance.collection("gyms").doc(userId).update({
          "name": gymNameController.text.trim(),
          "phone": phoneController.text.trim(),
        });
      }

      final snackBar = SnackBar(
        content: const Text('Profile Updated'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Update Gym Profile'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Gym Name",
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: gymNameController,
                    decoration: InputDecoration(
                      hintText: gymName,
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Phone Number",
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: phoneNumber,
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _changePassword(context),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Visibility(
                      visible: _isButtonVisible,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          gymNameController.text.trim() != gymName ||
                                  phoneController.text.trim() != phoneNumber
                              ? updateDb(userId)
                              : null;

                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'UPDATE PROFILE',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _changePassword(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            const TextSpan(
              text: "Want to change your password? click ",
              style: TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
            TextSpan(
                text: "HERE",
                style: const TextStyle(
                    color: Color(0xff1A1D1E),
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangePassword()),
                    );
                  }),
          ])),
    );
  }
}
