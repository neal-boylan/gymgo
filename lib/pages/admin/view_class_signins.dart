import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewClassSignins extends StatefulWidget {
  final String docId;
  const ViewClassSignins({super.key, required this.docId});

  @override
  State<ViewClassSignins> createState() => _ViewClassSigninsState(docId);
}

class _ViewClassSigninsState extends State<ViewClassSignins> {
  final String docId;
  _ViewClassSigninsState(this.docId);
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      print('docId: $docId');
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(docId)
          .get();

      if (doc.exists) {
        setState(() {
          items = List.from(doc['signins']); // Extract and store in state
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
        title: const Text('Class Signins'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: items.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading indicator
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index].toString()), // Display each item
                );
              },
            ),
    );
  }
}
