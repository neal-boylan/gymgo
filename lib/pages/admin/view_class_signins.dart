import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/sign_in_card.dart';
import 'edit_class.dart';

class ViewClassSignins extends StatefulWidget {
  final String docId;
  final bool coach;
  const ViewClassSignins({super.key, required this.docId, required this.coach});

  @override
  State<ViewClassSignins> createState() => _ViewClassSigninsState(docId);
}

class _ViewClassSigninsState extends State<ViewClassSignins> {
  final String docId;
  double listScreenSize = 0.75;
  _ViewClassSigninsState(this.docId);
  List<dynamic> signInList = [];
  List<dynamic> attendedList = [];

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
        setState(() {
          signInList = List.from(doc['signins']);
          attendedList = List.from(doc['attended']);
        });
        print('items: $signInList');
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Signins'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            signInList.isEmpty
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * listScreenSize,
                    child: Center(
                      child: const Text(
                        'No SignIns',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ) // Loading indicator
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("members")
                        .where(FieldPath.documentId, whereIn: signInList)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height *
                              listScreenSize,
                          child: Center(
                            child: const Text(
                              'No SignIns',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height *
                              listScreenSize,
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: attendedList.contains(snapshot
                                            .data!.docs[index]
                                            .data()['userId'])
                                        ? SignInCard(
                                            firstName: snapshot
                                                .data!.docs[index]
                                                .data()['firstName'],
                                            lastName: snapshot.data!.docs[index]
                                                .data()['lastName'],
                                            memberId: snapshot.data!.docs[index]
                                                .data()['userId'],
                                            docId: docId,
                                            attended: true,
                                          )
                                        : SignInCard(
                                            firstName: snapshot
                                                .data!.docs[index]
                                                .data()['firstName'],
                                            lastName: snapshot.data!.docs[index]
                                                .data()['lastName'],
                                            memberId: snapshot.data!.docs[index]
                                                .data()['userId'],
                                            docId: docId,
                                            attended: false,
                                          ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              color: Colors.white, // Background color for contrast
              child: widget.coach
                  ? null
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditClass(docId: docId),
                          ),
                        );
                      },
                      child: const Text(
                        'EDIT CLASS',
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
    );
  }
}
