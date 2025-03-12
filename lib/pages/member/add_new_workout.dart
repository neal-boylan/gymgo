import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/home_page.dart';

class AddNewWorkout extends StatefulWidget {
  const AddNewWorkout({super.key});

  @override
  State<AddNewWorkout> createState() => _AddNewWorkoutState();
}

class _AddNewWorkoutState extends State<AddNewWorkout> {
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

  Future<void> createWorkout() async {
    try {
      final userCredential = FirebaseAuth.instance.currentUser!.uid;
      addWorkoutToDb(userCredential);

      final snackBar = SnackBar(
        content: const Text('Workout added'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<void> addExercise(String ex, int s, int r, double w) async {
    try {
      // exercises.add(ex);
      // sets.add(s);
      // reps.add(r);
      // weight.add(w);
      setState(() {
        exercises = [...exercises, ex];
        sets = [...sets, s];
        reps = [...reps, r];
        weight = [...weight, w];
      });
      print('exercises: $ex, $s, $r, $w');
      final snackBar = SnackBar(
        content: const Text('Exercise added'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<void> addWorkoutToDb(String? userId) async {
    try {
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection("workouts").add({
        "exercise": exercises,
        "sets": sets,
        "reps": reps,
        "weight": weight,
        "userId": userId
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Workout'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              // const SizedBox(height: 10),
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
                  await addExercise(
                    exerciseController.text,
                    int.parse(setsController.text),
                    int.parse(repsController.text),
                    double.parse(weightController.text),
                  );
                  exerciseController.clear();
                  setsController.clear();
                  repsController.clear();
                  weightController.clear();
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
              Expanded(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      // title: Text(exercises![index].toString()),
                      title: Text(
                          '${exercises[index]} ${sets[index]} x ${reps[index]} ${weight[index]}kg'),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 50.0,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      onPressed: () {
                        createWorkout();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(),
                          ),
                        );
                      },
                      child: const Text(
                        'ADD WORKOUT',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
