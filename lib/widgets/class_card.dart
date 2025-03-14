import 'package:flutter/material.dart';

class ClassCard extends StatelessWidget {
  final Color color;
  final String title;
  final String coach;
  final String startTime;
  final String endTime;
  final int signins;
  final int size;
  final String uid;
  final void Function()? onTap;
  const ClassCard({
    super.key,
    required this.color,
    required this.title,
    required this.coach,
    required this.startTime,
    required this.endTime,
    required this.signins,
    required this.size,
    required this.uid,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        child: Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 25),
                    child: Text(
                      coach,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        startTime,
                        style: const TextStyle(fontSize: 17),
                      ),
                      Text(
                        ' - ',
                        style: const TextStyle(fontSize: 17),
                      ),
                      Text(
                        endTime,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "$signins/$size",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
