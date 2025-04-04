import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymgo/pages/static_variable.dart';

import '../home_page.dart';

class AddNewClass extends StatefulWidget {
  const AddNewClass({super.key});

  @override
  State<AddNewClass> createState() => _AddNewClassState();
}

// typedef MenuEntry = DropdownMenuEntry<String>;

class _AddNewClassState extends State<AddNewClass> {
  List<String> coachList = [];
  List<Map<String, dynamic>> coachDocList = [];
  List<String> coachNameList = [];
  List<String> coachIdList = [];

  String? selectedValue;

  @override
  void initState() {
    super.initState();
    fetchDropdownValues();
    fetchCoachDocuments();
  }

  Future<void> fetchCoachDocuments() async {
    List<String> nameValues = [];
    List<String> idValues = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('coaches')
        .where('gymId', isEqualTo: StaticVariable.gymIdVariable)
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.data() is Map<String, dynamic> &&
          (doc.data() as Map<String, dynamic>).containsKey('firstName')) {
        nameValues.add(doc['firstName'].toString());
        idValues.add(doc.id.toString());
      }
    }

    setState(() {
      coachDocList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      coachNameList = nameValues;
      coachIdList = idValues;
    });
  }

  // Function to fetch Firestore values
  Future<void> fetchDropdownValues() async {
    List<String> values = await getFieldValues("coaches", "firstName");
    setState(() {
      coachList = values;
      if (coachList.isNotEmpty) {
        selectedValue = coachList.first; // Set default selected value
      }
    });
  }

  // Function to get field values from Firestore
  Future<List<String>> getFieldValues(
      String collectionName, String fieldName) async {
    List<String> fieldValues = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('gymId', isEqualTo: StaticVariable.gymIdVariable)
          .get();
      for (var doc in querySnapshot.docs) {
        if (doc.data() is Map<String, dynamic> &&
            (doc.data() as Map<String, dynamic>).containsKey(fieldName)) {
          fieldValues
              .add(doc[fieldName].toString()); // Convert to string if needed
        }
      }
    } catch (e) {
      print("Error fetching field values: $e");
    }
    return fieldValues;
  }

  final titleController = TextEditingController();
  final coachController = TextEditingController();

  // static final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
  //   list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
  // );
  // String dropdownValue = list.first;

  final sizeController = TextEditingController();
  // List<dynamic> coachList = [];
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
      int index = coachNameList.indexOf(selectedValue.toString());
      String coachId = coachIdList[index];

      final data = await FirebaseFirestore.instance.collection("classes").add({
        "title": titleController.text.trim(),
        "coach": selectedValue,
        "coachId": coachId.toString(),
        "size": int.parse(sizeController.text.trim()),
        "startTime": startDateTime,
        "endTime": endDateTime,
        "weekly": weekly,
        "signins": [],
        "attended": [],
        "gymId": StaticVariable.gymIdVariable,
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
      print('e: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final startHours = startDateTime.hour.toString().padLeft(2, '0');
    final startMinutes = startDateTime.minute.toString().padLeft(2, '0');
    final endHours = endDateTime.hour.toString().padLeft(2, '0');
    final endMinutes = endDateTime.minute.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Add New Class'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          height: 50,
          margin: const EdgeInsets.all(10),
          child: ElevatedButton(
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
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
                SizedBox(height: 10),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    label: Text('Title'),
                  ),
                ),
                SizedBox(height: 10),
                coachNameList.isEmpty
                    ? CircularProgressIndicator() // Show loading indicator
                    : DropdownMenu<String>(
                        label: Text('Coach'),
                        expandedInsets: EdgeInsets.zero,
                        initialSelection: coachNameList.first,
                        onSelected: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            selectedValue = value!;
                          });
                        },
                        dropdownMenuEntries: coachNameList.map((String value) {
                          return DropdownMenuEntry<String>(
                            value: value,
                            label: value,
                          );
                        }).toList(),
                      ),
                SizedBox(height: 10),
                TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  controller: sizeController,
                  decoration: const InputDecoration(
                    hintText: '10',
                    label: Text('Class Size'),
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: 10),
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
                SizedBox(height: 10),
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
                    SizedBox(width: 10),
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

                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Start Time',
                        style: TextStyle(fontSize: 32),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 10),
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
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'End Time',
                        style: TextStyle(fontSize: 32),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 10),
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
                SizedBox(height: 10),
                // Expanded(
                //   child: Padding(
                //     padding: const EdgeInsets.only(
                //       left: 10,
                //       right: 10,
                //       bottom: 50.0,
                //     ),
                //     child: ElevatedButton(
                //       style: ElevatedButton.styleFrom(
                //           backgroundColor:
                //               Theme.of(context).colorScheme.primary),
                //       onPressed: () async {
                //         await uploadClassToDb();
                //         if (context.mounted) {
                //           Navigator.pop(context);
                //         }
                //         if (context.mounted) {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => MyHomePage(),
                //             ),
                //           );
                //         }
                //       },
                //       child: const Text(
                //         'SUBMIT',
                //         style: TextStyle(
                //           fontSize: 16,
                //           color: Colors.white,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
