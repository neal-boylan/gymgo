import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/admin/view_class_signins.dart';
import 'package:gymgo/widgets/date_selector.dart';
import 'package:gymgo/widgets/task_card.dart';
import 'package:intl/intl.dart';

import 'member/signin_class.dart';

class ClassList extends StatefulWidget {
  final bool val;
  const ClassList({super.key, required this.val});
  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  DateTime selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    print('ClassList.val: ${widget.val}');
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
            stream: FirebaseFirestore.instance
                .collection("classes")
                .where('startTime', isGreaterThanOrEqualTo: selectedDate)
                .where('startTime',
                    isLessThan: DateTime(selectedDate.year, selectedDate.month,
                        selectedDate.day + 1))
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
                            child: TaskCard(
                              color: Theme.of(context).colorScheme.primary,
                              headerText:
                                  snapshot.data!.docs[index].data()['title'],
                              descriptionText:
                                  snapshot.data!.docs[index].data()['coach'],
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
                              uid: FirebaseAuth.instance.currentUser!.uid,
                              onTap: () {
                                var docId = snapshot.data!.docs[index].id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => widget.val
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
