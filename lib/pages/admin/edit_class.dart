import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditClass extends StatefulWidget {
  final String docId;
  const EditClass({super.key, required this.docId});

  @override
  State<EditClass> createState() => _EditClassState(docId);
}

class _EditClassState extends State<EditClass> {
  final String docId;
  List<String> coachList = [];
  List<Map<String, dynamic>> coachDocList = [];
  List<String> coachNameList = [];
  List<String> coachIdList = [];
  DateTime classStartTime = DateTime.now();
  DateTime classEndTime = DateTime.now();
  String? selectedValue;

  _EditClassState(this.docId);

  final titleController = TextEditingController();
  final coachController = TextEditingController();
  final sizeController = TextEditingController();
  File? file;
  var title = "";
  var classSize = 10;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDropdownValues();
    fetchCoachDocuments();
  }

  Future<void> fetchCoachDocuments() async {
    List<String> nameValues = [];
    List<String> idValues = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('coaches').get();

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
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();
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

  Future<void> fetchData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(docId)
          .get();

      if (doc.exists) {
        // Map<String, dynamic>? data = docSnapshot.data();

        setState(() {
          title = doc['title'];
          classSize = doc['size'];
          titleController.text = title;
          sizeController.text = classSize.toString();
          classStartTime = doc['startTime'].toDate();
          classEndTime = doc['endTime'].toDate();
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    coachController.dispose();
    sizeController.dispose();
    super.dispose();
  }

  Future<void> editClassInDb() async {
    try {
      int index = coachNameList.indexOf(selectedValue.toString());
      String coachId = coachIdList[index];

      await FirebaseFirestore.instance.collection("classes").doc(docId).update(
        {
          'coach': selectedValue,
          "coachId": coachId.toString(),
          'size': int.parse(sizeController.text.trim()),
          'title': titleController.text.trim(),
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteClassFromnDb() async {
    try {
      print("deleting class: $docId");
      await FirebaseFirestore.instance
          .collection("classes")
          .doc(docId)
          .delete();

      print("class $docId deleted");
    } catch (e) {
      print(e);
    }
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
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Class'),
              Text(
                '${DateFormat('dd MMM y').format(classStartTime)}, '
                '${DateFormat('HH:mm').format(classStartTime)}-'
                '${DateFormat('HH:mm').format(classEndTime)}',
                style: TextStyle(
                  fontSize: 16, // Set your desired size here
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.66,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Description",
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: title,
                        // label: Text('Title'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Coach",
                      ),
                    ),
                    const SizedBox(height: 5),
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
                            dropdownMenuEntries:
                                coachNameList.map((String value) {
                              return DropdownMenuEntry<String>(
                                value: value,
                                label: value,
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Class Size",
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.number,
                      controller: sizeController,
                      decoration: InputDecoration(
                        hintText: classSize.toString(),
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                color: Colors.white, // Background color for contrast
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    await editClassInDb();
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                    // if (context.mounted) {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => MyHomePage(),
                    //     ),
                    //   );
                    // }
                  },
                  child: const Text(
                    'SAVE CHANGES',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                color: Colors.white, // Background color for contrast
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error),
                  onPressed: () async {
                    await deleteClassFromnDb();
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                    // if (context.mounted) {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => MyHomePage(),
                    //     ),
                    //   );
                    // }
                  },
                  child: const Text(
                    'DELETE CLASS',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
