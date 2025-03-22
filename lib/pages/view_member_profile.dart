import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/edit_member_profile.dart';

class ViewMemberProfile extends StatefulWidget {
  final String docId;
  final bool coach;
  final bool member;
  const ViewMemberProfile(
      {super.key,
      required this.docId,
      required this.coach,
      required this.member});

  @override
  State<ViewMemberProfile> createState() => _ViewMemberProfileState(docId);
}

class _ViewMemberProfileState extends State<ViewMemberProfile> {
  final String docId;
  _ViewMemberProfileState(this.docId);
  var firstName = "";
  var lastName = "";
  var email = "";
  var workouts = 0;
  var classes = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
    countClasses();
    countWorkouts();
  }

  Future<void> fetchData() async {
    try {
      var collection = FirebaseFirestore.instance.collection('members');
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

  Future<int> countWorkouts() async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('workouts');

    QuerySnapshot querySnapshot =
        await collection.where('userId', isEqualTo: docId).get();

    setState(() {
      workouts = querySnapshot.docs.length;
    });

    return querySnapshot.docs.length;
  }

  Future<int> countClasses() async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('classes');

    QuerySnapshot querySnapshot =
        await collection.where('signins', arrayContains: docId).get();

    setState(() {
      classes = querySnapshot.docs.length;
    });

    return querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.member
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

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     ElevatedButton(
                //       onPressed: () {},
                //       style: ElevatedButton.styleFrom(
                //         shape: CircleBorder(), // Makes it circular
                //         padding: EdgeInsets.all(20), // Adjusts size
                //       ),
                //       child: Icon(Icons.play_arrow), // You can use text too
                //     ),
                //     ElevatedButton(
                //       onPressed: () {},
                //       style: ElevatedButton.styleFrom(
                //         shape: CircleBorder(), // Makes it circular
                //         padding: EdgeInsets.all(20), // Adjusts size
                //       ),
                //       child: Icon(Icons.play_arrow), // You can use text too
                //     )
                //   ],
                // )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  EdgeInsetsDirectional.only(bottom: 150, start: 20, end: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding:
                            EdgeInsets.all(30), // Increase padding for size
                        minimumSize: Size(160, 160),
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // Fit text inside button
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Classes",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            classes.toString(),
                            style: TextStyle(
                              fontSize: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding:
                            EdgeInsets.all(30), // Increase padding for size
                        minimumSize: Size(160, 160),
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // Fit text inside button
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Workouts",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            workouts.toString(),
                            style: TextStyle(
                              fontSize: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  EdgeInsetsDirectional.only(bottom: 30, start: 20, end: 20),
              child: widget.member
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMemberProfile(),
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
                  : widget.coach
                      ? null
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error),
                          onPressed: () {},
                          child: Text(
                            'DELETE MEMBER ACCOUNT',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
            ),
          ),
        ],
        // children: [
        //   Padding(
        //     padding: const EdgeInsets.all(20.0),
        //     child: Center(
        //       child: Column(
        //         children: [
        //           const SizedBox(height: 10),
        //           Text(firstName),
        //           const SizedBox(height: 10),
        //           Text(lastName),
        //           const SizedBox(height: 10),
        //           Text(email),
        //           const SizedBox(height: 10),
        //           ElevatedButton(
        //             style: ElevatedButton.styleFrom(
        //                 backgroundColor: Theme.of(context).colorScheme.error),
        //             onPressed: () async {
        //               print("Delete Account button pressed");
        //             },
        //             child: const Text(
        //               'DELETE MEMBER ACCOUNT',
        //               style: TextStyle(
        //                 fontSize: 16,
        //                 color: Colors.white,
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ],
      ),
    );
  }
}
