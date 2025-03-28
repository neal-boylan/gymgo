import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/admin/edit_class.dart';

import '../../widgets/sign_in_card.dart';

class ViewClassSignins extends StatefulWidget {
  final String docId;
  const ViewClassSignins({super.key, required this.docId});

  @override
  State<ViewClassSignins> createState() => _ViewClassSigninsState(docId);
}

class _ViewClassSigninsState extends State<ViewClassSignins> {
  final String docId;
  _ViewClassSigninsState(this.docId);
  List<dynamic> items = [];
  List<dynamic> memberList = [];

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
          items = List.from(doc['signins']); // Extract and store in state
        });
        print('items: $items');
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
      body: Center(
        child: Column(
          children: [
            items.isEmpty
                ? Center(child: const Text('No SignIns')) // Loading indicator
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("members")
                        .where(FieldPath.documentId, whereIn: items)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(child: const Text('No SignIns'));
                      } else {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  // Expanded(
                                  //   child: ClassCard(
                                  //     color:
                                  //         Theme.of(context).colorScheme.primary,
                                  //     title: snapshot.data!.docs[index]
                                  //         .data()['firstName'],
                                  //     coach: snapshot.data!.docs[index]
                                  //         .data()['lastName'],
                                  //     startTime: "",
                                  //     endTime: "",
                                  //     signins: 0,
                                  //     size: 0,
                                  //     uid: "",
                                  //     onTap: () {},
                                  //   ),
                                  // ),
                                  Expanded(
                                    child: SignInCard(
                                      firstName: snapshot.data!.docs[index]
                                          .data()['firstName'],
                                      lastName: snapshot.data!.docs[index]
                                          .data()['lastName'],
                                      memberId: snapshot.data!.docs[index]
                                          .data()['userId'],
                                      docId: docId,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 50.0,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
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
              ),
            ),
          ],
        ),
      ),

      // ListView.builder(
      //         itemCount: items.length,
      //         itemBuilder: (context, index) {
      //           return ListTile(
      //             title: Text(items[index].toString()), // Display each item
      //           );
      //         },
      //       ),
    );
  }
}
