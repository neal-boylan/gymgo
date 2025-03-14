import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymgo/pages/home_page.dart';

class AddNewClass extends StatefulWidget {
  const AddNewClass({super.key});

  @override
  State<AddNewClass> createState() => _AddNewClassState();
}

class _AddNewClassState extends State<AddNewClass> {
  final titleController = TextEditingController();
  final coachController = TextEditingController();
  final sizeController = TextEditingController();
  List<String> signIns = [];
  DateTime startDateTime = DateTime.now();
  DateTime endDateTime = DateTime.now();
  DateTime selectedDate = DateTime.now();
  bool weekly = false;
  File? file;

  @override
  void dispose() {
    titleController.dispose();
    coachController.dispose();
    sizeController.dispose();
    super.dispose();
  }

  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: startDateTime,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );

  Future<TimeOfDay?> pickStartTime() => showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: startDateTime.hour, minute: startDateTime.minute),
      );

  Future<TimeOfDay?> pickEndTime() => showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: endDateTime.hour, minute: endDateTime.minute),
      );

  Future<void> uploadClassToDb() async {
    try {
      final data = await FirebaseFirestore.instance.collection("classes").add({
        "title": titleController.text.trim(),
        "coach": coachController.text.trim(),
        "size": int.parse(sizeController.text.trim()),
        "startTime": startDateTime,
        "endTime": endDateTime,
        "weekly": weekly,
        "signins": signIns,
      });

      final snackBar = SnackBar(
        content: const Text('Class added'),
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
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startHours = startDateTime.hour.toString().padLeft(2, '0');
    final startMinutes = startDateTime.minute.toString().padLeft(2, '0');
    final endHours = endDateTime.hour.toString().padLeft(2, '0');
    final endMinutes = endDateTime.minute.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Class'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // UNCOMMENT THIS in Firebase Storage section!

              // GestureDetector(
              //   onTap: () async {
              //     final image = await selectImage();
              //     setState(() {
              //       file = image;
              //     });
              //   },
              //   child: DottedBorder(
              //     borderType: BorderType.RRect,
              //     radius: const Radius.circular(10),
              //     dashPattern: const [10, 4],
              //     strokeCap: StrokeCap.round,
              //     child: Container(
              //       width: double.infinity,
              //       height: 150,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //       child: file != null
              //           ? Image.file(file!)
              //           : const Center(
              //               child: Icon(
              //                 Icons.camera_alt_outlined,
              //                 size: 40,
              //               ),
              //             ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 10),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: coachController,
                decoration: const InputDecoration(
                  hintText: 'Coach',
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.number,
                controller: sizeController,
                decoration: const InputDecoration(
                  hintText: '10',
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Weekly',
                    style: TextStyle(fontSize: 32),
                  ),
                  Checkbox(
                    value: weekly,
                    onChanged: (bool? value) {
                      setState(() {
                        weekly = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Date',
                      style: TextStyle(fontSize: 32),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      child: Text(
                        '${startDateTime.year}/${startDateTime.month}/${startDateTime.day}',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        final date = await pickDate();
                        if (date == null) return;

                        final newDateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          startDateTime.hour,
                          startDateTime.minute,
                        );
                        setState(() => startDateTime = newDateTime);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Start Time',
                      style: TextStyle(fontSize: 32),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      child: Text(
                        '$startHours:$startMinutes',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        final time = await pickStartTime();
                        if (time == null) return;

                        final newDateTime = DateTime(
                          startDateTime.year,
                          startDateTime.month,
                          startDateTime.day,
                          time.hour,
                          time.minute,
                        );
                        setState(
                          () {
                            startDateTime = newDateTime;
                            endDateTime =
                                startDateTime.add(const Duration(hours: 1));
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'End Time',
                      style: TextStyle(fontSize: 32),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      child: Text(
                        '$endHours:$endMinutes',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        final time = await pickEndTime();
                        if (time == null) return;

                        final newDateTime = DateTime(
                          endDateTime.year,
                          endDateTime.month,
                          endDateTime.day,
                          time.hour,
                          time.minute,
                        );
                        setState(() => endDateTime = newDateTime);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  await uploadClassToDb();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(),
                      ),
                    );
                  }
                },
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
