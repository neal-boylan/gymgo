import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../static_variable.dart';

class AddNewMember extends StatefulWidget {
  const AddNewMember({super.key});

  @override
  State<AddNewMember> createState() => _AddNewMemberState();
}

class _AddNewMemberState extends State<AddNewMember> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  bool coach = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void Validate(String email) {
    bool isvalid = EmailValidator.validate(email);
    print(isvalid);
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      if (EmailValidator.validate(emailController.text.trim()) == true) {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        addMemberToDb(userCredential.user?.uid);

        final snackBar = SnackBar(
          content: const Text('Member added'),
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
      } else {
        final snackBar = SnackBar(
          content: const Text('Member not added'),
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
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<void> addMemberToDb(String? userId) async {
    try {
      // final data = await FirebaseFirestore.instance.collection("members").add({
      //   "email": emailController.text.trim(),
      //   "password": passwordController.text.trim(),
      //   "firstName": firstNameController.text.trim(),
      //   "lastName": lastNameController.text.trim(),
      //   "userId": userId
      // });

      if (coach) {
        await FirebaseFirestore.instance.collection("coaches").doc(userId).set({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "userId": userId,
          "gymId": StaticVariable.gymIdVariable,
        });
      } else {
        await FirebaseFirestore.instance.collection("members").doc(userId).set({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "userId": userId,
          "gymId": StaticVariable.gymIdVariable,
        });
      }

      // print(data.id);
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Add New Member'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.text,
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        label: Text('First Name'),
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.text,
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        label: Text('Last Name'),
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: const InputDecoration(
                        label: Text('Email'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      controller: passwordController,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        label: Text('Password'),
                      ),
                      maxLines: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Assign Coaching privileges?',
                          style: TextStyle(fontSize: 20),
                        ),
                        Checkbox(
                          value: coach,
                          onChanged: (bool? value) {
                            setState(() {
                              coach = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                color: Colors.white,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    await createUserWithEmailAndPassword();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    // if (context.mounted) {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => MyHomePage(),
                    //     ),
                    //   );
                    // }
                  },
                  child: const Text(
                    'ADD MEMBER',
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
      ),
    );
  }
}
