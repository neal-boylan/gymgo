import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewProfile extends StatefulWidget {
  final String docId;
  const ViewProfile({super.key, required this.docId});

  @override
  State<ViewProfile> createState() => _ViewProfileState(docId);
}

class _ViewProfileState extends State<ViewProfile> {
  final String docId;
  _ViewProfileState(this.docId);
  var firstName = "";
  var lastName = "";
  var email = "";
  var workouts = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
    countWorkouts();
  }

  Future<void> fetchData() async {
    try {
      print('docId: $docId');
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
    // Get reference to the collection
    CollectionReference collection =
        FirebaseFirestore.instance.collection('workouts');

    // Query to find documents where the field matches the value
    QuerySnapshot querySnapshot =
        await collection.where('userId', isEqualTo: docId).get();

    setState(() {
      workouts = querySnapshot.docs.length;
    });

    // Return the number of documents
    return querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                            "55",
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error),
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
