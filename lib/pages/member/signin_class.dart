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
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  _SignInClassState(this.docId);
  List<dynamic> signedIn = [];
  int size = 10;

  Future<void> addMemberClassToDb() async {
    try {
      FirebaseFirestore.instance.collection("classes").doc(docId).update({
        'signins': FieldValue.arrayUnion([uid])
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeMemberClassFromDb() async {
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
      print('docId: $docId');
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(docId)
          .get();

      if (doc.exists) {
        print('doc exists');
        setState(() {
          signedIn = List.from(doc['signins']); // Extract and store in state
          size = doc['size'];

          print('signedIn.length: ${signedIn.length}');
          print('size: ${size}');
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
        title: const Text('Sign In To Class'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      // body: signedIn.length < size
      //     ? SingleChildScrollView(
      //         child: Padding(
      //           padding: const EdgeInsets.all(20.0),
      //           child: Column(
      //             children: [
      //               const SizedBox(height: 10),
      //               !signedIn.contains(uid)
      //                   ? ElevatedButton(
      //                       style: ElevatedButton.styleFrom(
      //                           backgroundColor:
      //                               Theme.of(context).colorScheme.primary),
      //                       onPressed: () async {
      //                         await addMemberClassToDb();
      //                         if (context.mounted) {
      //                           Navigator.pop(context);
      //                         }
      //                       },
      //                       child: const Text(
      //                         'SIGN IN TO CLASS',
      //                         style: TextStyle(
      //                           fontSize: 16,
      //                           color: Colors.white,
      //                         ),
      //                       ),
      //                     )
      //                   : ElevatedButton(
      //                       style: ElevatedButton.styleFrom(
      //                           backgroundColor:
      //                               Theme.of(context).colorScheme.primary),
      //                       onPressed: () async {
      //                         await removeMemberClassFromDb();
      //                         if (context.mounted) {
      //                           Navigator.pop(context);
      //                         }
      //                       },
      //                       child: const Text(
      //                         'CANCEL BOOKING',
      //                         style: TextStyle(
      //                           fontSize: 16,
      //                           color: Colors.white,
      //                         ),
      //                       ),
      //                     ),
      //             ],
      //           ),
      //         ),
      //       )
      //     : Padding(
      //         padding: const EdgeInsets.all(20.0),
      //         child: Center(
      //           child: const Text('Class is full'),
      //         ),
      //       ),
      body: signedIn.contains(uid) // signedIn.length < size
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      onPressed: () async {
                        await removeMemberClassFromDb();
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
              ),
            )
          : signedIn.length < size
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary),
                          onPressed: () async {
                            await addMemberClassToDb();
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
