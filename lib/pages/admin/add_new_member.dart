import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          "userId": userId
        });
      } else {
        await FirebaseFirestore.instance.collection("members").doc(userId).set({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "userId": userId
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  hintText: 'First Name',
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  hintText: 'Last Name',
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                obscureText: true,
                controller: passwordController,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
                maxLines: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Assign Coaching privelages?',
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
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  await createUserWithEmailAndPassword();
                },
                child: const Text(
                  'ADD MEMBER',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
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
