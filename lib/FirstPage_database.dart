import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final DatabaseReference _databaseReference = FirebaseDatabase(databaseURL: 'https://the-book-list-18073-default-rtdb.europe-west1.firebasedatabase.app/').reference();

  String firstValue = "";

  @override
  void initState() {
    super.initState();
    _getFirstValue();
  }

  Future<void> _getFirstValue() async {
    try {
      DataSnapshot snapshot = (await _databaseReference.once()) as DataSnapshot;
      if (snapshot.value != null) {
        // Get the first child's value
        setState(() {
          // Cast the value to String
          firstValue = (snapshot.value.toString());
        });
      } else {
        setState(() {
          firstValue = "";
        });
      }
    } catch (error) {
      print('Failed to retrieve data: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Database Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Open a new widget
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SecondPage(),
              ),
            );
          },
          child: Text(
            'First Value: $firstValue',
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Center(
        child: Text('This is the second page.'),
      ),
    );
  }
}