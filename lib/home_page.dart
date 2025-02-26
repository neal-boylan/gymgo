import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/add_new_class.dart';
import 'package:gymgo/add_new_member.dart';
import 'package:gymgo/login_page.dart';

import 'class_list.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int pageIndex = 0;
  final String? userId = FirebaseAuth.instance.currentUser!.uid;
  final String? userEmail = FirebaseAuth.instance.currentUser!.email;
  final members = FirebaseFirestore.instance.collection("members");
  bool _val = true;

  Future<bool> checkIfMember() async {
    // bool val = false;
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('members')
        .where("userId", isEqualTo: userId)
        .get();

    if (snap.docs.isNotEmpty) {
      DocumentSnapshot doc = snap.docs.first;
      print(doc['userId']);
      _val = true;
      return true; //like this you can access data
    } else {
      print("Doc doesn't exist");
      _val = false;
      return false;
    }
  }

  final List<Widget> pages = [
    const ClassList(),
    const AddNewMember(),
  ];

  DateTime selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();

  Future<void> signOutUser() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> queryValues() async {
    print('queryVals');
    List myList = [];
    // getting all the documents from fb snapshot
    final snapshot = await FirebaseFirestore.instance
        .collection("classes")
        .where('weekly', isEqualTo: true)
        .where('startTime',
            isLessThan: DateTime(
                currentDate.year, currentDate.month, currentDate.day + 7))
        .get();

    // check if the collection is not empty before handling it
    if (snapshot.docs.isNotEmpty) {
      // add all items to myList
      myList.addAll(snapshot.docs);
    }

    for (var gymClass in snapshot.docs) {
      var setting = false;

      print(gymClass.data().toString());

      if (setting == true) {
        try {
          final data =
              await FirebaseFirestore.instance.collection("classes").add({
            "title": gymClass.data()['title'],
            "coach": gymClass.data()['coach'],
            "size": gymClass.data()['size'],
            "startTime": DateTime(
                gymClass.data()['startTime'].year,
                gymClass.data()['startTime'].month,
                gymClass.data()['startTime'].day + 7),
            "endTime": DateTime(
                gymClass.data()['endTime'].year,
                gymClass.data()['endTime'].month,
                gymClass.data()['endTime'].day + 7),
            "weekly": gymClass.data()['title'],
          });
          print(data.id);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfMember().then((updatedVal) {
      //The `then` is Triggered once the Future completes without errors
      //And here I can update my var _val.

      //The setState method forces a rebuild of the Widget tree
      //Which will update the view with the new value of `_val`
      setState(() {
        _val = updatedVal;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        title:
            pageIndex == 0 ? const Text('Classes') : const Text('Add Member'),
        actions: [
          IconButton(
            onPressed: () async {
              await signOutUser();
              if (!context.mounted) return;
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            icon: const Icon(
              CupertinoIcons.arrow_uturn_left,
            ),
          ),
        ],
      ),
      body: pages[pageIndex],
      floatingActionButton: _val
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddNewClass(),
                  ),
                );
              },
            )
          : null,
      bottomNavigationBar: _val
          ? Container(
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      setState(() {
                        pageIndex = 0;
                      });
                    },
                    icon: pageIndex == 0
                        ? const Icon(
                            Icons.home_filled,
                            color: Colors.white,
                            size: 35,
                          )
                        : const Icon(
                            Icons.home_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      setState(() {
                        pageIndex = 1;
                      });
                    },
                    icon: pageIndex == 1
                        ? const Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 35,
                          )
                        : const Icon(
                            Icons.person_add_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                ],
              ),
            )
          : Container(
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      setState(() {
                        pageIndex = 0;
                      });
                    },
                    icon: pageIndex == 0
                        ? const Icon(
                            Icons.home_filled,
                            color: Colors.white,
                            size: 35,
                          )
                        : const Icon(
                            Icons.home_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      setState(() {
                        pageIndex = 1;
                      });
                    },
                    icon: pageIndex == 1
                        ? const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 35,
                          )
                        : const Icon(
                            Icons.fitness_center_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
