import 'package:flutter/material.dart';

// class SignInCard extends StatelessWidget {
//   final String firstName;
//   final String lastName;
//   final String uid;
//   final bool isChecked;
//   final void Function()? onTap;
//   const SignInCard({
//     super.key,
//     required this.firstName,
//     required this.lastName,
//     required this.uid,
//     required this.isChecked,
//     this.onTap,
//   });

class SignInCard extends StatefulWidget {
  const SignInCard(
      {super.key,
      required this.firstName,
      required this.lastName,
      required this.memberId});

  final String firstName;
  final String lastName;
  final String memberId;

  @override
  State<SignInCard> createState() => _SignInCardState();
}

class _SignInCardState extends State<SignInCard> {
  // String firstName = "";
  // String lastName = "";
  // String memberId = "";
  bool isChecked = false;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.firstName} ${widget.lastName}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
                shape: CircleBorder(), // Makes the checkbox circular
                checkColor: Colors.white,
                activeColor: Colors.blue,
              )
            ],
          ),
        ),
      ),
    );
  }
}
