import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/admin/view_class_signins.dart';
import 'package:gymgo/widgets/date_selector.dart';
import 'package:intl/intl.dart';

import '../widgets/class_card.dart';
import 'member/signin_class.dart';

class ClassList extends StatefulWidget {
  final bool member;
  final bool coach;
  const ClassList({super.key, required this.member, required this.coach});
  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  DateTime selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          DateSelector(
            selectedDate: selectedDate,
            onTap: (date) {
              setState(() {
                selectedDate = DateTime(date.year, date.month, date.day);
              });
            },
          ),
          StreamBuilder(
            stream: widget.coach
                ? FirebaseFirestore.instance
                    .collection("classes")
                    .where('startTime', isGreaterThanOrEqualTo: selectedDate)
                    .where('startTime',
                        isLessThan: DateTime(selectedDate.year,
                            selectedDate.month, selectedDate.day + 1))
                    .where('coach',
                        isEqualTo:
                            'June') //FirebaseAuth.instance.currentUser!.uid.toString())
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection("classes")
                    .where('startTime', isGreaterThanOrEqualTo: selectedDate)
                    .where('startTime',
                        isLessThan: DateTime(selectedDate.year,
                            selectedDate.month, selectedDate.day + 1))
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              // if (!snapshot.hasData) {
              if (snapshot.data!.docs.isEmpty) {
                return Center(child: const Text('No Classes Today'));
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DateFormat dateFormat = DateFormat('Hm');
                      return Row(
                        children: [
                          Expanded(
                            child: ClassCard(
                              color: Theme.of(context).colorScheme.primary,
                              title: snapshot.data!.docs[index].data()['title'],
                              coach: snapshot.data!.docs[index].data()['coach'],
                              startTime: dateFormat
                                  .format(snapshot.data!.docs[index]
                                      .data()['startTime']
                                      .toDate())
                                  .toString(),
                              endTime: dateFormat
                                  .format(snapshot.data!.docs[index]
                                      .data()['endTime']
                                      .toDate())
                                  .toString(),
                              signins: snapshot.data!.docs[index]
                                  .data()['signins']
                                  .length,
                              size: snapshot.data!.docs[index].data()['size'],
                              uid: FirebaseAuth.instance.currentUser!.uid,
                              onTap: () {
                                var docId = snapshot.data!.docs[index].id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => widget.member
                                        ? SignInClass(
                                            docId: docId,
                                          )
                                        : ViewClassSignins(
                                            docId: docId,
                                          ),
                                  ),
                                );
                              },
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
        ],
      ),
    );
  }
}
