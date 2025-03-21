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

  @override
  void initState() {
    super.initState();
    fetchData();
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
              children: [
                SizedBox(height: 50),
                CircleAvatar(
                  radius: 80, // Adjust size
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Image URL
                  backgroundColor: Colors.grey[300], // Placeholder color
                  child: Icon(Icons.person,
                      size: 50, color: Colors.white), // Placeholder icon
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
              ],
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
