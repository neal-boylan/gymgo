import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInClass extends StatefulWidget {
  final String docId;
  const SignInClass({super.key, required this.docId});

  @override
  State<SignInClass> createState() => _SignInClassState(docId);
}

class _SignInClassState extends State<SignInClass> {
  final String docId;
  _SignInClassState(this.docId);

  Future<void> addMemberClassToDb() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      print('uid: $uid');
      FirebaseFirestore.instance.collection("classes").doc(docId).update({
        'signins': FieldValue.arrayUnion([uid])
      });
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
