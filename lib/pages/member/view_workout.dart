import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewWorkout extends StatefulWidget {
  final String docId;
  const ViewWorkout({super.key, required this.docId});

  @override
  State<ViewWorkout> createState() => _ViewWorkoutState(docId);
}

class _ViewWorkoutState extends State<ViewWorkout> {
  final String docId;
  _ViewWorkoutState(this.docId);
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
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('workouts')
          .doc(docId)
          .get();

      if (doc.exists) {
        setState(() {
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
        title: const Text('Workout'),
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
                        return ListTile(
                          // title: Text(exercises![index].toString()),
                          title: Text(
                              '${exercise[index]} ${sets[index]} x ${reps[index]} ${weight[index]}kg'),
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
