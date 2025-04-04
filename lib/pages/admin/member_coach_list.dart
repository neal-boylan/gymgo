import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/admin/view_member_profile.dart';

import '../../utils/static_variable.dart';
import '../../widgets/member_card.dart';
import '../coach/view_coach_profile.dart';

class MemberCoachList extends StatefulWidget {
  final bool coach;
  const MemberCoachList({super.key, required this.coach});
  @override
  State<MemberCoachList> createState() => _MemberCoachListState();
}

class _MemberCoachListState extends State<MemberCoachList> {
  bool showCoaches = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Members"),
              Switch(
                value: showCoaches,
                onChanged: (value) {
                  setState(() {
                    showCoaches = value;
                  });
                },
              ),
              Text("Coaches"),
            ],
          ),
          const SizedBox(height: 10),
          showCoaches
              ? StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("coaches")
                      .where('gymId', isEqualTo: StaticVariable.gymIdVariable)
                      .orderBy("firstName")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    // if (!snapshot.hasData) {
                    if (snapshot.data!.docs.isEmpty) {
                      return Center(child: const Text('No Coaches'));
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                  child: MemberCard(
                                    firstName: snapshot.data!.docs[index]
                                        .data()['firstName'],
                                    lastName: snapshot.data!.docs[index]
                                        .data()['lastName'],
                                    uid: FirebaseAuth.instance.currentUser!.uid,
                                    onTap: () {
                                      var docId = snapshot.data!.docs[index].id;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewCoachProfile(
                                            docId: docId,
                                            coach: false,
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
                )
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("members")
                      .where('gymId', isEqualTo: StaticVariable.gymIdVariable)
                      .orderBy("firstName")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    // if (!snapshot.hasData) {
                    if (snapshot.data!.docs.isEmpty) {
                      return Center(child: const Text('No Members'));
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                  child: MemberCard(
                                    firstName: snapshot.data!.docs[index]
                                        .data()['firstName'],
                                    lastName: snapshot.data!.docs[index]
                                        .data()['lastName'],
                                    uid: FirebaseAuth.instance.currentUser!.uid,
                                    onTap: () {
                                      var docId = snapshot.data!.docs[index].id;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewMemberProfile(
                                            docId: docId,
                                            coach: widget.coach,
                                            member: false,
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
    );
  }
}
