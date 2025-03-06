import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/member/view_workout.dart';
import 'package:gymgo/widgets/task_card.dart';

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
    return Center(
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
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              // if (!snapshot.hasData) {
              if (snapshot.data!.docs.isEmpty) {
                return Center(child: const Text('No Workouts'));
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: TaskCard(
                              color: Theme.of(context).colorScheme.primary,
                              headerText: snapshot.data!.docs[index].id,
                              descriptionText:
                                  snapshot.data!.docs[index].data()['userId'],
                              startTime: "",
                              endTime: "",
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
        ],
      ),
    );
  }
}
