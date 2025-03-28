import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/member/edit_exercise.dart';
import 'package:intl/intl.dart';

import '../../widgets/exercise_card.dart';
import 'edit_workout.dart';

class ViewWorkout extends StatefulWidget {
  final String docId;
  const ViewWorkout({super.key, required this.docId});

  @override
  State<ViewWorkout> createState() => _ViewWorkoutState(docId);
}

class _ViewWorkoutState extends State<ViewWorkout> {
  final String docId;
  _ViewWorkoutState(this.docId);
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
      print('docId: $docId');
      String formatTimestamp(Timestamp timestamp) {
        DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
        return DateFormat('E dd MMM yyyy')
            .format(dateTime); // Format as Mon 25 Feb 2025
      }

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(docId)
          .get();

      if (doc.exists) {
        setState(() {
          workoutDate = formatTimestamp(doc['workoutDate']).toString();
          exercise = List.from(doc['exercise']);
          sets = List.from(doc['sets']);
          reps = List.from(doc['reps']);
          weight = List.from(doc['weight']); // Extract and store in state
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditExercise(
                                        docId: docId,
                                        index: index,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                        ListTile(
                          // title: Text(exercises![index].toString()),
                          title: Text(
                              '${exercise[index]} ${sets[index]} x ${reps[index]} ${weight[index]}kg'),
                        );
                      },
                    ),
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditWorkout(docId: docId),
                              ),
                            );
                          },
                          child: const Text(
                            'EDIT WORKOUT',
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
    );
  }
}
