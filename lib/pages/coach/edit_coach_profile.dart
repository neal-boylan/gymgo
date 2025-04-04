import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/utils/change_password.dart';

import '../home_page.dart';

class EditCoachProfile extends StatefulWidget {
  const EditCoachProfile({super.key});

  @override
  State<EditCoachProfile> createState() => _EditCoachProfileState();
}

class _EditCoachProfileState extends State<EditCoachProfile> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isButtonVisible = false;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();

  var firstName = "";
  var lastName = "";

  bool coach = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    firstNameController.addListener(() {
      setState(() {
        _isButtonVisible = firstNameController.text.isNotEmpty ||
            lastNameController.text.isNotEmpty;
      });
    });

    lastNameController.addListener(() {
      setState(() {
        _isButtonVisible = lastNameController.text.isNotEmpty ||
            firstNameController.text.isNotEmpty;
      });
    });
  }

  Future<void> fetchData() async {
    try {
      var collection = FirebaseFirestore.instance.collection('coaches');
      var docSnapshot = await collection.doc(userId).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();

        setState(() {
          firstName = data?['firstName'];
          lastName = data?['lastName'];
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
      if (firstNameController.text.trim() == "") {
        await FirebaseFirestore.instance
            .collection("coaches")
            .doc(userId)
            .update({
          "lastName": lastNameController.text.trim(),
        });
      } else if (lastNameController.text.trim() == "") {
        await FirebaseFirestore.instance
            .collection("coaches")
            .doc(userId)
            .update({
          "firstName": firstNameController.text.trim(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection("coaches")
            .doc(userId)
            .update({
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
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
          title: Text('Update Profile'),
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
                      "First Name",
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      hintText: firstName,
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Last Name",
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      hintText: lastName,
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.text,
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
                          firstNameController.text.trim() != firstName ||
                                  lastNameController.text.trim() != lastName
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
