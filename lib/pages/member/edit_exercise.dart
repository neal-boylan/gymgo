import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/member/view_workout.dart';

class EditExercise extends StatefulWidget {
  final String docId;
  final int index;
  const EditExercise({super.key, required this.docId, required this.index});

  @override
  State<EditExercise> createState() => _EditExerciseState(docId, index);
}

class _EditExerciseState extends State<EditExercise> {
  final String docId;
  final int index;
  _EditExerciseState(this.docId, this.index);

  final exerciseController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();
  final weightController = TextEditingController();
  List<String> exercises = [];
  List<int> sets = [];
  List<int> reps = [];
  List<double> weight = [];

  @override
  void dispose() {
    exerciseController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadExerciseData();
  }

  Future<void> _loadExerciseData() async {
    DocumentSnapshot exerciseDoc = await FirebaseFirestore.instance
        .collection('workouts')
        .doc(docId)
        .get();

    if (exerciseDoc.exists) {
      setState(() {
        exerciseController.text = exerciseDoc['exercise'][index];
        setsController.text = exerciseDoc['sets'][index].toString();
        repsController.text = exerciseDoc['reps'][index].toString();
        weightController.text = exerciseDoc['weight'][index].toString();
      });
    }
  }

  Future<void> updateExercise(String listName, String newValue) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('workouts');

    DocumentSnapshot doc = await users.doc(docId).get();
    if (doc.exists) {
      List<dynamic> items = List.from(doc[listName]);

      items[index] = newValue;
      await users.doc(docId).update({
        listName: items,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workout'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: exerciseController,
                decoration: const InputDecoration(
                  hintText: 'Exercise',
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      decoration: const InputDecoration(
                        hintText: 'Sets',
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TextFormField(
                      controller: repsController,
                      decoration: const InputDecoration(
                        hintText: 'Reps',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TextFormField(
                      controller: weightController,
                      decoration: const InputDecoration(
                        hintText: 'Weight',
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  await updateExercise(
                    'exercise',
                    exerciseController.text,
                  );
                  await updateExercise(
                    'sets',
                    setsController.text,
                  );
                  await updateExercise(
                    'reps',
                    repsController.text,
                  );
                  await updateExercise(
                    'weight',
                    weightController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewWorkout(docId: docId),
                      ),
                    );
                  }
                },
                child: const Text(
                  'UPDATE EXERCISE',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
