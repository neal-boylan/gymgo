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
  @override
  void initState() {
    super.initState();
  }

  Future<void> deleteWorkoutFromDb(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection("workouts")
          .doc(docId)
          .delete();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
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
                if (snapshot.data!.docs.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        'No Workouts Logged',
                        style: GoogleFonts.raleway(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data!.docs[index]
                            .data()['dateAdded']
                            .toString();
                        DateFormat dateFormat = DateFormat('E dd MMM yyyy');
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
                                      'Are you sure you want to delete this workout?'),
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
                            var docId = snapshot.data!.docs[index].id;
                            setState(() {
                              deleteWorkoutFromDb(docId);
                            });
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                                SnackBar(content: Text('workout deleted')));
                          },
                          background: Container(
                              color: Theme.of(context).colorScheme.error),
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
