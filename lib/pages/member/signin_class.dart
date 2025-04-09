import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SignInClass extends StatefulWidget {
  final String docId;
  const SignInClass({super.key, required this.docId});

  @override
  State<SignInClass> createState() => _SignInClassState(docId);
}

class _SignInClassState extends State<SignInClass> {
  final String docId;
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  _SignInClassState(this.docId);
  List<dynamic> signedIn = [];
  int size = 10;
  DateTime classStartTime = DateTime.now();
  DateTime classEndTime = DateTime.now();

  Future<void> addMemberToClassDb() async {
    try {
      FirebaseFirestore.instance.collection("classes").doc(docId).update({
        'signins': FieldValue.arrayUnion([uid])
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeMemberFromClassDb() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      print('uid: $uid');
      FirebaseFirestore.instance.collection("classes").doc(docId).update({
        'signins': FieldValue.arrayRemove([uid])
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(docId)
          .get();

      if (doc.exists) {
        setState(() {
          signedIn = List.from(doc['signins']); // Extract and store in state
          size = doc['size'];
          classStartTime = doc['startTime'].toDate();
          classEndTime = doc['endTime'].toDate();
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sign In to Class'),
            Text(
              '${DateFormat('dd MMM y').format(classStartTime)}, '
              '${DateFormat('HH:mm').format(classStartTime)}-'
              '${DateFormat('HH:mm').format(classEndTime)}',
              style: TextStyle(
                fontSize: 16, // Set your desired size here
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: signedIn.contains(uid)
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () async {
                      await removeMemberFromClassDb();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'CANCEL BOOKING',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : signedIn.length < size
              ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          await addMemberToClassDb();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'SIGN IN TO CLASS',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: const Text('Class is full'),
                  ),
                ),
    );
  }
}
