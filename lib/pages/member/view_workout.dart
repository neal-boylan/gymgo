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
                        return Dismissible(
                          key: Key(item),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            // Show confirmation dialog
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Confirmation'),
                                  content: Text(
                                      'Are you sure you want to delete "$item"?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            setState(() {
                              exercises.removeAt(index);
                              reps.removeAt(index);
                              sets.removeAt(index);
                              weight.removeAt(index);
                              updateWorkoutInDb();
                            });
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                                SnackBar(content: Text('$item dismissed')));
                          },
                          background: Container(color: Colors.red),
                          child: ExerciseCard(
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
                          ),
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
