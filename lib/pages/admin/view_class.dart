import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/sign_in_card.dart';
import 'edit_class.dart';

class ViewClass extends StatefulWidget {
  final String docId;
  final bool coach;
  const ViewClass({super.key, required this.docId, required this.coach});

  @override
  State<ViewClass> createState() => _ViewClassState(docId);
}

class _ViewClassState extends State<ViewClass> {
  final String docId;
  double listScreenSize = 0.75;
  _ViewClassState(this.docId);
  List<dynamic> signInList = [];
  List<dynamic> attendedList = [];
  DateTime classStartTime = DateTime.now();
  DateTime classEndTime = DateTime.now();

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
          signInList = List.from(doc['signins']);
          attendedList = List.from(doc['attended']);
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
            Text('Class Signins'),
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
      body: SafeArea(
        child: Column(
          children: [
            signInList.isEmpty
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * listScreenSize,
                    child: Center(
                      child: const Text(
                        'No Signins',
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
