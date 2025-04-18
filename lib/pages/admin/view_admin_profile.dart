import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'edit_admin_profile.dart';

class ViewAdminProfile extends StatefulWidget {
  final String docId;
  const ViewAdminProfile({super.key, required this.docId});

  @override
  State<ViewAdminProfile> createState() => _ViewAdminProfileState(docId);
}

class _ViewAdminProfileState extends State<ViewAdminProfile> {
  final String docId;
  _ViewAdminProfileState(this.docId);
  var email = "";
  var gymName = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var collection = FirebaseFirestore.instance.collection('gyms');
      var docSnapshot = await collection.doc(docId).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();

        setState(() {
          gymName = data?['name'];
          email = data?['email'];
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> refreshClasses() async {
    try {
      List myList = [];

      // define how far into the past to search for weekly classes
      // define how far into the future weekly classes will be created
      Timestamp nowTimestamp = Timestamp.now();
      DateTime nowDateTime = nowTimestamp.toDate();
      DateTime pastDateTime = nowDateTime.add(Duration(days: -8));
      Timestamp pastTimestamp = Timestamp.fromDate(pastDateTime);
      DateTime futureDateTime = nowDateTime.add(Duration(days: 10));

      // getting all the documents from snapshot
      final snapshot = await FirebaseFirestore.instance
          .collection("classes")
          .where('weekly', isEqualTo: true)
          .where('startTime', isGreaterThanOrEqualTo: pastTimestamp)
          .get();

      // check if the collection is not empty before handling it
      if (snapshot.docs.isNotEmpty) {
        // add all items to myList
        myList.addAll(snapshot.docs);
      }

      for (var gymClass in snapshot.docs) {
        Timestamp startTimestamp = gymClass.data()['startTime'];
        DateTime startDateTime = startTimestamp.toDate();
        DateTime newStartDateTime = startDateTime.add(Duration(days: 7));
        Timestamp newStartTimestamp = Timestamp.fromDate(newStartDateTime);

        Timestamp endTimestamp = gymClass.data()['endTime'];
        DateTime endDateTime = endTimestamp.toDate();
        DateTime newEndDateTime = endDateTime.add(Duration(days: 7));
        Timestamp newEndTimestamp = Timestamp.fromDate(newEndDateTime);

        while (!newStartDateTime.isAfter(futureDateTime)) {
          try {
            final check = await FirebaseFirestore.instance
                .collection("classes")
                .where('startTime', isEqualTo: newStartTimestamp)
                .get();

            if (check.docs.isEmpty) {
              await FirebaseFirestore.instance.collection("classes").add({
                "title": gymClass.data()['title'],
                "coach": gymClass.data()['coach'],
                "coachId": gymClass.data()['coachId'],
                "gymId": gymClass.data()['gymId'],
                "size": gymClass.data()['size'],
                "startTime": newStartTimestamp,
                "endTime": newEndTimestamp,
                "signins": [],
                "attended": [],
                "weekly": gymClass.data()['weekly'],
              });
            }
            newStartDateTime = newStartDateTime.add(Duration(days: 7));
            newStartTimestamp = Timestamp.fromDate(newStartDateTime);
            newEndDateTime = endDateTime.add(Duration(days: 7));
            newEndTimestamp = Timestamp.fromDate(newEndDateTime);
          } catch (e) {
            print(e);
          }
        }
      }
      final snackBar = SnackBar(
        content: const Text('Classes Refreshed'),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: 160, // Diameter
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .primaryColor, // Background color if no image
                      ),
                      child: Center(
                        child: gymName == ""
                            ? null
                            : Text(
                                gymName.substring(0, 1),
                                style: TextStyle(
                                  fontSize: 48,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      gymName,
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 10),
                    Text(
                      email,
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
              color: Colors.white, // Background color for contrast
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  refreshClasses();
                },
                child: const Text(
                  'REFRESH CLASSES',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
              color: Colors.white, // Background color for contrast
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAdminProfile(),
                    ),
                  );
                },
                child: const Text(
                  'EDIT PROFILE',
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
    );
  }
}
