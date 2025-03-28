import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'edit_coach_profile.dart';

class ViewCoachProfile extends StatefulWidget {
  final String docId;
  final bool coach;
  final bool member;
  const ViewCoachProfile(
      {super.key,
      required this.docId,
      required this.coach,
      required this.member});

  @override
  State<ViewCoachProfile> createState() => _ViewCoachProfileState(docId);
}

class _ViewCoachProfileState extends State<ViewCoachProfile> {
  final String docId;
  _ViewCoachProfileState(this.docId);
  var firstName = "";
  var lastName = "";
  var email = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var collection = FirebaseFirestore.instance.collection('coaches');
      var docSnapshot = await collection.doc(docId).get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();

        setState(() {
          firstName = data?['firstName'];
          lastName = data?['lastName'];
          email = data?['email'];
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.coach
          ? null
          : AppBar(
              title: Text('$firstName\'s profile'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
      body: Stack(
        children: [
          Center(
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
                    child: firstName == ""
                        ? null
                        : Text(
                            "${firstName.substring(0, 1)}${lastName.substring(0, 1)}",
                            style: TextStyle(
                              fontSize: 48,
                              color: Colors.black,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '$firstName $lastName',
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  EdgeInsetsDirectional.only(bottom: 30, start: 20, end: 20),
              child: widget.coach
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditCoachProfile(),
                          ),
                        );
                      },
                      child: Text(
                        'EDIT PROFILE',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error),
                      onPressed: () {},
                      child: Text(
                        'DELETE COACH ACCOUNT',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
