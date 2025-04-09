import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/member/edit_exercise.dart';
import 'package:intl/intl.dart';

import '../../widgets/exercise_card.dart';
import 'add_exercise.dart';

class ViewWorkout extends StatefulWidget {
  final String docId;
  const ViewWorkout({super.key, required this.docId});

  @override
  State<ViewWorkout> createState() => _ViewWorkoutState();
}

class _ViewWorkoutState extends State<ViewWorkout> {
  // final String docId;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  String memberId = "";
  _ViewWorkoutState();
  String workoutDate = "";
  List<dynamic> exercise = [];
  List<dynamic> reps = [];
  List<dynamic> sets = [];
  List<dynamic> weight = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      String formatTimestamp(Timestamp timestamp) {
        DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
        return DateFormat('E dd MMM yyyy')
            .format(dateTime); // Format as Mon 25 Feb 2025
      }

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(widget.docId)
          .get();

      if (doc.exists) {
        setState(() {
          workoutDate = formatTimestamp(doc['workoutDate']).toString();
          exercise = List.from(doc['exercise']);
          sets = List.from(doc['sets']);
          reps = List.from(doc['reps']);
          weight = List.from(doc['weight']);
          memberId = doc['userId'];
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
        title: Text('Workout, $workoutDate'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: exercise.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : Center(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercise.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          children: [
                            Expanded(
                              child: ExerciseCard(
                                color: Theme.of(context).colorScheme.primary,
                                exercise: exercise[index],
                                sets: sets[index].toString(),
                                reps: reps[index].toString(),
                                weight: weight[index].toString(),
                                onTap: () {
                                  memberId == userId
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditExercise(
                                              docId: widget.docId,
                                              index: index,
                                            ),
                                          ),
                                        )
                                      : null;
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 50.0,
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: memberId == userId
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddExercise(docId: widget.docId),
                                  ),
                                );
                              },
                              child: const Text(
                                'ADD EXERCISE TO WORKOUT',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
