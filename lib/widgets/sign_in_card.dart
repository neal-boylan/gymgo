import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignInCard extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String memberId;
  final bool attended;
  final String docId;

  const SignInCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.memberId,
    required this.attended,
    required this.docId,
  });

  @override
  State<SignInCard> createState() => _SignInCardState();
}

class _SignInCardState extends State<SignInCard> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.attended; // Set initial value from parent
  }

  Future<void> addMemberToAttendedDb(String memberId) async {
    try {
      FirebaseFirestore.instance
          .collection("classes")
          .doc(widget.docId)
          .update({
        'attended': FieldValue.arrayUnion([memberId])
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeMemberFromAttendedDb(String memberId) async {
    try {
      FirebaseFirestore.instance
          .collection("classes")
          .doc(widget.docId)
          .update({
        'attended': FieldValue.arrayRemove([memberId])
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        padding: const EdgeInsets.symmetric(vertical: 20.0).copyWith(
          left: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
              color: Theme.of(context).colorScheme.primary, width: 3),
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${widget.firstName} ${widget.lastName}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Transform.scale(
                scale: 1.5,
                child: Checkbox(
                  value: isChecked, // widget.attended,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                    if (value != null) {
                      value
                          ? addMemberToAttendedDb(widget.memberId)
                          : removeMemberFromAttendedDb(widget.memberId);
                    }
                  },
                  shape: CircleBorder(),
                  checkColor: Colors.white,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
