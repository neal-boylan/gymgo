import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignInClass extends StatefulWidget {
  const SignInClass({super.key});

  @override
  State<SignInClass> createState() => _SignInClassState();
}

class _SignInClassState extends State<SignInClass> {
  Future<void> addMemberClassToDb() async {
    try {
      FirebaseFirestore.instance
          .collection("classes")
          .doc('gInp8sfvBDwJiRx86qaC')
          .update({'coach': 'Dave'});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In To Class'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  await addMemberClassToDb();
                },
                child: const Text(
                  'SIGN In',
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
