import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/signin_class.dart';
import 'package:gymgo/widgets/date_selector.dart';
import 'package:gymgo/widgets/task_card.dart';
import 'package:intl/intl.dart';

class ClassList extends StatefulWidget {
  const ClassList({super.key});

  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  DateTime selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();

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
          // FutureBuilder(
          //   future: FirebaseFirestore.instance.collection("classes").get(),
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
                      DateFormat _dateFormat = DateFormat('Hm');
                      return Row(
                        children: [
                          Expanded(
                            child: TaskCard(
                              color: Theme.of(context).colorScheme.primary,
                              headerText:
                                  snapshot.data!.docs[index].data()['title'],
                              descriptionText:
                                  snapshot.data!.docs[index].data()['coach'],
                              startTime: _dateFormat
                                  .format(snapshot.data!.docs[index]
                                      .data()['startTime']
                                      .toDate())
                                  .toString(),
                              endTime: _dateFormat
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
                                    builder: (context) => SignInClass(
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
