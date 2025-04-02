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

  @override
  void initState() {
    super.initState();
  }

  Future<void> refreshClasses() async {
    try {
      List myList = [];

      // define how far into the past to search for weekly classes
      // define how far into the future weekly classes will be created
      Timestamp nowTimestamp = Timestamp.now();
      DateTime nowDateTime = nowTimestamp.toDate();
      DateTime pastDateTime = nowDateTime.add(Duration(days: -7));
      Timestamp pastTimestamp = Timestamp.fromDate(pastDateTime);
      DateTime futureDateTime = nowDateTime.add(Duration(days: 8));
      Timestamp futureTimestamp = Timestamp.fromDate(futureDateTime);

      // getting all the documents from fb snapshot
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
                "size": gymClass.data()['size'],
                "startTime": newStartTimestamp,
                "endTime": newEndTimestamp,
                "signins": [],
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
      print('classes refreshed');
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
                        // image: DecorationImage(
                        //   image: NetworkImage('https://via.placeholder.com/150'),
                        //   fit: BoxFit.cover, // Ensures image fills the circle
                        // ),
                        color: Theme.of(context)
                            .primaryColor, // Background color if no image
                      ),
                      child: Center(
                        child: Text(
                          "GYM",
                          style: TextStyle(
                            fontSize: 36,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Gym Name',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 10),
                    Text(
                      email,
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Phone Number",
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
