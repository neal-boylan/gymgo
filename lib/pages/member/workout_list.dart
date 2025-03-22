import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymgo/pages/member/add_new_workout.dart';
import 'package:gymgo/pages/member/view_workout.dart';

import '../../widgets/class_card.dart';

class WorkoutList extends StatefulWidget {
  const WorkoutList({super.key});
  @override
  State<WorkoutList> createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
  DateTime selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Workouts'),
      //   backgroundColor: Theme.of(context).primaryColor,
      // ),
      body: Center(
        child: Column(
          children: [
            // FutureBuilder(
            //   future: FirebaseFirestore.instance.collection("classes").get(),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("workouts")
                  .where('userId',
                      isEqualTo:
                          FirebaseAuth.instance.currentUser!.uid.toString())
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
                      'No Workouts Logged',
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
                        return Row(
                          children: [
                            Expanded(
                              child: ClassCard(
                                color: Theme.of(context).colorScheme.primary,
                                title: snapshot.data!.docs[index].id,
                                coach:
                                    snapshot.data!.docs[index].data()['userId'],
                                startTime: "",
                                endTime: "",
                                signins: 0,
                                size: 0,
                                uid: FirebaseAuth.instance.currentUser!.uid,
                                onTap: () {
                                  var docId = snapshot.data!.docs[index].id;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewWorkout(
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
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 10.0,
                top: 10.0,
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
                        builder: (context) => AddNewWorkout(),
                      ),
                    );
                  },
                  child: const Text(
                    'ADD NEW WORKOUT',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
