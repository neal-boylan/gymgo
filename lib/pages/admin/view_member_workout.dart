import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/member/edit_exercise.dart';
import 'package:intl/intl.dart';

import '../../widgets/exercise_card.dart';

class ViewMemberWorkout extends StatefulWidget {
  final String docId;
  const ViewMemberWorkout({super.key, required this.docId});

  @override
  State<ViewMemberWorkout> createState() => _ViewMemberWorkoutState();
}

class _ViewMemberWorkoutState extends State<ViewMemberWorkout> {
  // final String docId;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  String memberId = "";
  _ViewMemberWorkoutState();
  String workoutDate = "";
  List<dynamic> exercises = [];
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
          exercises = List.from(doc['exercise']);
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

  Future<void> updateWorkoutInDb() async {
    try {
      final workoutDoc =
          FirebaseFirestore.instance.collection('workouts').doc(widget.docId);

      await workoutDoc.update({
        "exercise": exercises,
        "sets": sets,
        "reps": reps,
        "weight": weight,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout, $workoutDate'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: exercises.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : Center(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = exercises[index];
                        return ExerciseCard(
                          color: Theme.of(context).colorScheme.primary,
                          exercise: exercises[index],
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
