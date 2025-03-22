import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/change_password.dart';

class EditMemberProfile extends StatefulWidget {
  const EditMemberProfile({super.key});

  @override
  State<EditMemberProfile> createState() => _EditMemberProfileState();
}

class _EditMemberProfileState extends State<EditMemberProfile> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
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
  }

  Future<void> fetchData() async {
    try {
      var collection = FirebaseFirestore.instance.collection('members');
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
            .collection("members")
            .doc(userId)
            .update({
          "lastName": lastNameController.text.trim(),
        });
      } else if (lastNameController.text.trim() == "") {
        await FirebaseFirestore.instance
            .collection("members")
            .doc(userId)
            .update({
          "firstName": firstNameController.text.trim(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection("members")
            .doc(userId)
            .update({
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
        });
      }

      // print(data.id);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: firstName.toString(),
                  decoration: InputDecoration(
                    // labelText: "First Name",
                    border: OutlineInputBorder(),
                  ),
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
                ),
                const SizedBox(height: 20),
                _changePassword(context),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () async {
                      firstNameController.text.trim() != firstName ||
                              lastNameController.text.trim() != lastName
                          ? updateDb(userId)
                          : null;
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
              ],
            ),
          ),
        ],
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
