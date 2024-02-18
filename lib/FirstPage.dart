import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'bookToDataBase.dart'; // If not needed, you can remove this import

class FirstPage extends StatefulWidget {
  final String userEmail;
  const FirstPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF21BFBD),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Welcome!',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontStyle: FontStyle.italic,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'This App is for Books Geeks Like myself, Hope you enjoy it!',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontStyle: FontStyle.italic,
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'If you don\'t find your book, you can add it!',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontStyle: FontStyle.italic,
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Open a new widget
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBookToDataBasePage(
                    userEmail: widget.userEmail,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.blue[600],
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Add a book to the DB.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
