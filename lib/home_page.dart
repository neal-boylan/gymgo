import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymgo/login_page.dart';
import 'package:gymgo/widgets/date_selector.dart';
import 'package:gymgo/widgets/task_card.dart';
import 'package:intl/intl.dart';

import 'add_new_class.dart';

class MyHomePage extends StatefulWidget {
  // static route() => MaterialPageRoute(
  //       builder: (context) => const MyHomePage(),
  //     );
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime selectedDate = DateTime.now();

  Future<void> signOutUser() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        title: const Text('Classes'),
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
      body: Center(
        child: Column(
          children: [
            DateSelector(
              selectedDate: selectedDate,
              onTap: (date) {
                setState(() {
                  selectedDate = DateTime(date.year, date.month, date.day);
                });
              },
            ),
            // FutureBuilder(
            //   future: FirebaseFirestore.instance.collection("classes").get(),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("classes")
                  .where('startTime', isGreaterThanOrEqualTo: selectedDate)
                  .where('startTime',
                      isLessThan: DateTime(selectedDate.year,
                          selectedDate.month, selectedDate.day + 1))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // if (!snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: const Text('No Classes Today'));
                } else {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DateFormat _dateFormat = DateFormat('Hm');
                        return Row(
                          children: [
                            Expanded(
                              child: TaskCard(
                                color: Theme.of(context).colorScheme.primary,
                                headerText:
                                    snapshot.data!.docs[index].data()['title'],
                                descriptionText:
                                    snapshot.data!.docs[index].data()['coach'],
                                startTime: _dateFormat
                                    .format(snapshot.data!.docs[index]
                                        .data()['startTime']
                                        .toDate())
                                    .toString(),
                                endTime: _dateFormat
                                    .format(snapshot.data!.docs[index]
                                        .data()['endTime']
                                        .toDate())
                                    .toString(),
                              ),
                            ),
                            // Container(
                            //   height: 50,
                            //   width: 50,
                            //   decoration: BoxDecoration(
                            //     color: strengthenColor(
                            //       const Color.fromRGBO(246, 222, 194, 1),
                            //       0.69,
                            //     ),
                            //     shape: BoxShape.circle,
                            //   ),
                            // ),
                            // const Padding(
                            //   padding: EdgeInsets.all(12.0),
                            //   child: Text(
                            //     '10:00AM',
                            //     style: TextStyle(
                            //       fontSize: 17,
                            //     ),
                            //   ),
                            // )
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
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.primary,
        child: Container(height: 50.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
