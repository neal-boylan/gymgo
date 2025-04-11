import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/member/view_workout.dart';

class AddExercise extends StatefulWidget {
  final String docId;
  const AddExercise({super.key, required this.docId});

  @override
  State<AddExercise> createState() => _AddExerciseState(docId);
}

class _AddExerciseState extends State<AddExercise> {
  final String docId;
  _AddExerciseState(this.docId);

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

  Future<void> addExercise(String listName, String newItem) async {
    Object addItem;
    if (listName == 'exercise') {
      addItem = newItem;
    } else if (listName == 'weight') {
      addItem = double.parse(newItem);
    } else if (listName == 'sets') {
      addItem = int.parse(newItem);
    } else if (listName == 'reps') {
      addItem = int.parse(newItem);
    } else {
      addItem = newItem;
    }

    await FirebaseFirestore.instance.collection('workouts').doc(docId).update({
      listName: FieldValue.arrayUnion([addItem])
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Exercise to Workout'),
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
                    label: Text('Exercise'),
                  ),
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: setsController,
                        decoration: const InputDecoration(
                          label: Text('Sets'),
                        ),
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TextFormField(
                        controller: repsController,
                        decoration: const InputDecoration(
                          label: Text('Reps'),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TextFormField(
                        controller: weightController,
                        decoration: const InputDecoration(
                          label: Text('Weight'),
                        ),
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    await addExercise(
                      'exercise',
                      exerciseController.text,
                    );
                    await addExercise(
                      'sets',
                      setsController.text,
                    );
                    await addExercise(
                      'reps',
                      repsController.text,
                    );
                    await addExercise(
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
                    'ADD EXERCISE',
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
      ),
    );
  }
}
