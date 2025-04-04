import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymgo/pages/member/add_new_workout.dart';
import 'package:gymgo/pages/member/view_workout.dart';
import 'package:intl/intl.dart';

import '../../widgets/workout_card.dart';

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
                  .orderBy('workoutDate', descending: true)
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
                        DateFormat dateFormat = DateFormat('E dd MMM yyyy');
                        return Row(
                          children: [
                            Expanded(
                              child: WorkoutCard(
                                color: Theme.of(context).colorScheme.primary,
                                workoutDate: dateFormat
                                    .format(snapshot.data!.docs[index]
                                        .data()['workoutDate']
                                        .toDate())
                                    .toString(),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNewWorkout(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
