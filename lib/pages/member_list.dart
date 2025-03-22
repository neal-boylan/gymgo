import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/pages/view_member_profile.dart';
import 'package:intl/intl.dart';

import '../widgets/member_card.dart';

class MemberList extends StatefulWidget {
  final bool coach;
  final bool member;
  const MemberList({super.key, required this.coach, required this.member});
  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  DateTime selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("members")
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
                      DateFormat dateFormat = DateFormat('Hm');
                      return Row(
                        children: [
                          Expanded(
                            child: MemberCard(
                              firstName: snapshot.data!.docs[index]
                                  .data()['firstName'],
                              lastName:
                                  snapshot.data!.docs[index].data()['lastName'],
                              uid: FirebaseAuth.instance.currentUser!.uid,
                              onTap: () {
                                var docId = snapshot.data!.docs[index].id;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewMemberProfile(
                                      docId: docId,
                                      coach: widget.coach,
                                      member: widget.member,
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
