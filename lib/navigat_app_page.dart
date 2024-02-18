import 'package:books_app/FirstPage.dart';
import 'package:books_app/temp_toreadsearch.dart';
import 'package:books_app/ThirdPage.dart';
import 'package:flutter/material.dart';

import 'book_database.dart';

class NavigatAppPage extends StatefulWidget {
  final userEmail;
  const NavigatAppPage({Key? key, required this.userEmail}) : super(key: key);
  @override
  State<NavigatAppPage> createState() => _NavigatAppPageState();
}

class _NavigatAppPageState extends State<NavigatAppPage> {
  int _currentIndex = 0;
  late String userEmail;
  late List<Widget> _pages;
  late DatabaseService databaseService ;

  @override
  void initState() {
    userEmail = widget.userEmail;
    databaseService = DatabaseService.getInstance(userEmail: userEmail);
    //databaseService.insertBooks();
    //databaseService.insertBooks('assets/goodreads_data - goodreads_data.csv.csv');
    _pages = [
      FirstPage(userEmail: userEmail),
      SecondPage(userEmail: userEmail),
      ThirdPage(userEmail: userEmail)
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_sharp),
            label: 'Favourites Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_add_outlined),
            label: 'RecommendationSystem',
          ),
        ],
      ),
    );
  }
}
