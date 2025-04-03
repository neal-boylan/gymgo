import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymgo/pages/signup_page.dart';

import '../services/auth_service.dart';

class LoginPage2 extends StatefulWidget {
  const LoginPage2({super.key});

  @override
  State<LoginPage2> createState() => _LoginPage2State();
}

// typedef MenuEntry = DropdownMenuEntry<String>;

class _LoginPage2State extends State<LoginPage2> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<String> gymList = [];
  List<Map<String, dynamic>> gymDocList = [];
  List<String> gymNameList = ['1', '2'];
  List<String> gymIdList = [];
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    fetchDropdownValues();
    fetchCoachDocuments();
  }

  Future<void> fetchCoachDocuments() async {
    List<String> nameValues = [];
    List<String> idValues = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('gyms').get();

    for (var doc in querySnapshot.docs) {
      if (doc.data() is Map<String, dynamic> &&
          (doc.data() as Map<String, dynamic>).containsKey('name')) {
        nameValues.add(doc['name'].toString());
        idValues.add(doc.id.toString());
      }
    }

    setState(() {
      gymDocList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      gymNameList = nameValues;
      gymIdList = idValues;
    });
  }

  // Function to fetch Firestore values
  Future<void> fetchDropdownValues() async {
    List<String> values = await getFieldValues("gyms", "name");
    setState(() {
      gymList = values;
      if (gymList.isNotEmpty) {
        selectedValue = gymList.first; // Set default selected value
      }
    });
    print("fetchDropdownValues got");
  }

  // Function to get field values from Firestore
  Future<List<String>> getFieldValues(
      String collectionName, String fieldName) async {
    List<String> fieldValues = [];
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();
      for (var doc in querySnapshot.docs) {
        if (doc.data() is Map<String, dynamic> &&
            (doc.data() as Map<String, dynamic>).containsKey(fieldName)) {
          fieldValues
              .add(doc[fieldName].toString()); // Convert to string if needed
        }
      }
      print("getFieldValues got");
    } catch (e) {
      print("Error fetching field values: $e");
    }
    return fieldValues;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: _signup(context),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Find your Gym below and Log In',
                    style: GoogleFonts.raleway(
                        textStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 32)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                _gymPicker(),
                const SizedBox(
                  height: 20,
                ),
                _emailAddress(),
                const SizedBox(
                  height: 20,
                ),
                _password(),
                const SizedBox(
                  height: 20,
                ),
                _signin(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gymPicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gymNameList.isEmpty
            ? CircularProgressIndicator() // Show loading indicator
            : DropdownMenu<String>(
                label: Text('Find Your Gym'),
                expandedInsets: EdgeInsets.zero,
                initialSelection: gymNameList.first,
                onSelected: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    selectedValue = value!;
                  });
                },
                dropdownMenuEntries: gymNameList.map((String value) {
                  return DropdownMenuEntry<String>(
                    value: value,
                    label: value,
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _emailAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            filled: true,
            label: Text('Email Address'),
            // hintText: 'email@gmail.com',
            hintStyle: const TextStyle(
                color: Color(0xff6A6A6A),
                fontWeight: FontWeight.normal,
                fontSize: 14),
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        )
      ],
    );
  }

  Widget _password() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          obscureText: true,
          controller: _passwordController,
          decoration: InputDecoration(
            label: Text('Password'),
            filled: true,
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          keyboardType: TextInputType.visiblePassword,
        )
      ],
    );
  }

  Widget _signin(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      onPressed: () async {
        await AuthService().signin(
            email: _emailController.text,
            password: _passwordController.text,
            context: context);
      },
      child: const Text(
        "LOGIN",
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: "Gym Owner? Click ",
              style: TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
            TextSpan(
              text: "HERE",
              style: const TextStyle(
                  color: Color(0xff1A1D1E),
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
            ),
            const TextSpan(
              text: " to register with GYMGO",
              style: TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
