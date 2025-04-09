import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymgo/pages/member/view_workout.dart';
import 'package:intl/intl.dart';

import '../../widgets/workout_card.dart';

class ViewMemberWorkouts extends StatefulWidget {
  final String memberId;
  const ViewMemberWorkouts({super.key, required this.memberId});
  @override
  State<ViewMemberWorkouts> createState() => _ViewMemberWorkoutsState();
}

class _ViewMemberWorkoutsState extends State<ViewMemberWorkouts> {
  var firstName = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var collection = FirebaseFirestore.instance.collection('members');
      var docSnapshot = await collection.doc(widget.memberId).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();

        setState(() {
          firstName = data?['firstName'];
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
        title: Text('$firstName\'s Workouts'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("workouts")
                  .orderBy('workoutDate', descending: true)
                  .where('userId', isEqualTo: widget.memberId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                // if (!snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return Expanded(
                    child: Center(
                        child: Text(
                      'No Workouts Logged',
                      style: GoogleFonts.raleway(
                          textStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 32)),
                      textAlign: TextAlign.center,
                    )),
                  );
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DateFormat dateFormat = DateFormat('E dd MMM yyyy');
                        return Row(
                          children: [
                            Expanded(
                              child: WorkoutCard(
                                color: Theme.of(context).colorScheme.primary,
                                workoutDate: dateFormat
                                    .format(snapshot.data!.docs[index]
                                        .data()['workoutDate']
                                        .toDate())
                                    .toString(),
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
      ),
    );
  }
}
