import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymgo/pages/admin/view_class_signins.dart';
import 'package:gymgo/pages/static_variable.dart';
import 'package:gymgo/widgets/date_selector.dart';
import 'package:intl/intl.dart';

import '../widgets/class_card.dart';
import 'member/signin_class.dart';

class ClassList extends StatefulWidget {
  final bool member;
  final bool coach;
  const ClassList({
    super.key,
    required this.member,
    required this.coach,
  });
  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime currentDate = DateTime.now();
  String _gymId = "";

  @override
  void initState() {
    super.initState();

    getGymId(FirebaseAuth.instance.currentUser!.uid).then((updatedVal) {
      setState(() {
        _gymId = updatedVal!;
      });
    });
  }

  Future<String?> getGymId(String userId) async {
    try {
      DocumentSnapshot doc;
      if (widget.member) {
        doc = await FirebaseFirestore.instance
            .collection('members')
            .doc(userId)
            .get();
      } else if (widget.coach) {
        doc = await FirebaseFirestore.instance
            .collection('coaches')
            .doc(userId)
            .get();
      } else {
        doc = await FirebaseFirestore.instance
            .collection('gyms')
            .doc(userId)
            .get();
      }

      if (doc.exists) {
        return doc['gymId'];
      } else {
        return "No gym found";
      }
    } catch (e) {
      print("Error fetching document: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("StaticVariable.gymIdVariable: ${StaticVariable.gymIdVariable}");
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
                    .where('gymId', isEqualTo: StaticVariable.gymIdVariable)
                    .where('startTime', isGreaterThanOrEqualTo: selectedDate)
                    .where('startTime',
                        isLessThan: DateTime(selectedDate.year,
                            selectedDate.month, selectedDate.day + 1))
                    .where('coachId',
                        isEqualTo:
                            FirebaseAuth.instance.currentUser!.uid.toString())
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection("classes")
                    .where('gymId', isEqualTo: StaticVariable.gymIdVariable)
                    .where('startTime', isGreaterThanOrEqualTo: selectedDate)
                    .where('startTime',
                        isLessThan: DateTime(selectedDate.year,
                            selectedDate.month, selectedDate.day + 1))
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Expanded(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              // if (!snapshot.hasData) {
              if (snapshot.data!.docs.isEmpty) {
                return Expanded(
                  child: Center(
                      child: Text(
                    'No Classes Today',
                    style: GoogleFonts.raleway(
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 32)),
                    textAlign: TextAlign.center,
                  )),
                );
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
                                snapshot.data!.docs[index]
                                        .data()['startTime']
                                        .toDate()
                                        .isAfter(DateTime.now())
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => widget.member
                                              ? SignInClass(
                                                  docId: docId,
                                                )
                                              : ViewClassSignins(
                                                  docId: docId,
                                                  coach: widget.coach,
                                                ),
                                        ),
                                      )
                                    : print('doc clicked: $docId');
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
