import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/admin/add_new_member.dart';
import 'package:gymgo/pages/member_list.dart';
import 'package:gymgo/pages/view_coach_profile.dart';
import 'package:gymgo/pages/view_member_profile.dart';

import '../services/auth_service.dart';
import 'admin/add_new_class.dart';
import 'class_list.dart';
import 'member/workout_list.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // DateTime selectedDate = DateTime.now();
  DateTime selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime currentDate = DateTime.now();
  int pageIndex = 0;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final String? userEmail = FirebaseAuth.instance.currentUser!.email;
  final members = FirebaseFirestore.instance.collection("members");
  bool _member = true;
  bool _coach = true;

  Future<bool> checkIfMember() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('members')
        .where("userId", isEqualTo: userId)
        .get();

    if (snap.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkIfCoach() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('coaches')
        .where("userId", isEqualTo: userId)
        .get();

    if (snap.docs.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  final List<Widget> pages = [
    const ClassList(
      member: false,
      coach: false,
    ),
    const MemberList(
      coach: false,
      member: false,
    ),
    const AddNewMember(),
  ];

  final List<Widget> coachPages = [
    const ClassList(
      member: false,
      coach: true,
    ),
    const MemberList(
      coach: true,
      member: false,
    ),
    ViewCoachProfile(
      docId: FirebaseAuth.instance.currentUser!.uid,
      coach: true,
      member: false,
    ),
  ];

  final List<Widget> memberPages = [
    const ClassList(
      member: true,
      coach: false,
    ),
    const WorkoutList(),
    ViewMemberProfile(
      docId: FirebaseAuth.instance.currentUser!.uid,
      coach: false,
      member: true,
    ),
  ];

  Future<void> signOutUser() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> queryValues() async {
    List myList = [];

    // define how far into the past to search for weekly classes
    // define how far into the future weekly classes will be created
    Timestamp nowTimestamp = Timestamp.now();
    DateTime nowDateTime = nowTimestamp.toDate();
    DateTime pastDateTime = nowDateTime.add(Duration(days: -7));
    Timestamp pastTimestamp = Timestamp.fromDate(pastDateTime);
    DateTime futureDateTime = nowDateTime.add(Duration(days: 7));
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
      setState(() {
        _member = updatedVal;
      });
    });

    checkIfCoach().then((updatedVal) {
      setState(() {
        _coach = updatedVal;
      });
    });

    queryValues();
  }

  String _getAppBarTitle(int page) {
    if (_member) {
      switch (page) {
        case 0:
          return "Home, member\n$userEmail";
        case 1:
          return "Workouts, member\n$userEmail";
        case 2:
          return "Profile, member\n$userEmail";
        default:
          return "Flutter App, member\n$userEmail";
      }
    } else if (_coach) {
      switch (page) {
        case 0:
          return "Home, coach\n$userEmail";
        case 1:
          return "Member List, coach\n$userEmail";
        case 2:
          return "Profile, coach\n$userEmail";
        default:
          return "Flutter App, coach\n$userEmail";
      }
    } else {
      switch (page) {
        case 0:
          return "Home, admin\n$userEmail";
        case 1:
          return "Member List, admin\n$userEmail";
        case 2:
          return "Member List, admin\n$userEmail";
        default:
          return "Flutter App, admin\n$userEmail";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        title: Text(_getAppBarTitle(pageIndex)),
        actions: [
          IconButton(
            onPressed: () async {
              // await signOutUser();
              // if (!context.mounted) return;
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (context) => LoginPage()));
              await AuthService().signout(context: context);
            },
            icon: const Icon(
              CupertinoIcons.arrow_uturn_left,
            ),
          ),
        ],
      ),
      body: _member
          ? memberPages[pageIndex]
          : _coach
              ? coachPages[pageIndex]
              : pages[pageIndex],
      floatingActionButton: _member || _coach
          ? null
          : pageIndex == 0
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
              : pageIndex == 1
                  ? FloatingActionButton.large(
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      child: Icon(Icons.person_add),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddNewMember(),
                          ),
                        );
                      },
                    )
                  : null,
      bottomNavigationBar: _member
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
                            size: 60,
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
                            size: 60,
                          )
                        : const Icon(
                            Icons.fitness_center_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      setState(() {
                        pageIndex = 2;
                      });
                    },
                    icon: pageIndex == 2
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 60,
                          )
                        : const Icon(
                            Icons.person_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                ],
              ),
            )
          : _coach
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
                                size: 60,
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
                                Icons.people,
                                color: Colors.white,
                                size: 60,
                              )
                            : const Icon(
                                Icons.people_outline,
                                color: Colors.white,
                                size: 35,
                              ),
                      ),
                      IconButton(
                        enableFeedback: false,
                        onPressed: () {
                          setState(() {
                            pageIndex = 2;
                          });
                        },
                        icon: pageIndex == 2
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 60,
                              )
                            : const Icon(
                                Icons.person_outlined,
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
                                size: 60,
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
                                Icons.people,
                                color: Colors.white,
                                size: 60,
                              )
                            : const Icon(
                                Icons.people_outlined,
                                color: Colors.white,
                                size: 35,
                              ),
                      ),
                      IconButton(
                        enableFeedback: false,
                        onPressed: () {
                          setState(() {
                            pageIndex = 2;
                          });
                        },
                        icon: pageIndex == 2
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 60,
                              )
                            : const Icon(
                                Icons.person_outlined,
                                color: Colors.white,
                                size: 35,
                              ),
                      ),
                    ],
                  ),
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
