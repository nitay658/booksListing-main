import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:books_app/book_database.dart';

class AddBookPage extends StatefulWidget {
  final String userEmail;

  const AddBookPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final List<Book> _allBooks = [];
  List<Book> searchResults = [];
  late Set<Book> selectedBooks;
  late DatabaseService databaseService;
  final TextEditingController _textEditingController = TextEditingController();
  final StreamController<List<Book>> _searchController =
  BehaviorSubject<List<Book>>.seeded([]);

  @override
  void initState() {
    super.initState();
    databaseService = DatabaseService.getInstance(userEmail: widget.userEmail);
    _getBooks();
    _textEditingController.addListener(_onSearchTextChanged);
    selectedBooks = {};
  }

  @override
  void dispose() {
    _searchController.close();
    _textEditingController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    List<Book> filteredBooks = _allBooks
        .where((book) =>
        book.title.toLowerCase().contains(_textEditingController.text.toLowerCase()))
        .toList();
    _searchController.add(filteredBooks);
  }

  void _getBooks() {
    var lst = databaseService.getAllBooks();
    lst.listen((List<Book> run) {
      setState(() {
        _allBooks.addAll(run);
        searchResults = List.from(_allBooks);
        _searchController.add(searchResults);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF21BFBD),
      appBar: CupertinoNavigationBar(
        middle: CupertinoSearchTextField(
          backgroundColor: Colors.white,
          controller: _textEditingController,
          onChanged: (text) => _onSearchTextChanged(),
        ),
      ),
      body: _buildBookList(),
    );
  }

  Widget _buildBookList() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          const SizedBox(height: 40.0),
          Container(
            height: MediaQuery.of(context).size.height - 185.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
            ),
            child: StreamBuilder<List<Book>>(
              stream: _searchController.stream,
              builder: (context, snapshot) {
                return _buildDataBaseBookListView(snapshot);
              },
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: _buildAddButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataBaseBookListView(AsyncSnapshot<List<Book>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text('Error: ${snapshot.error}'),
      );
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(
        child: Text('No books available.'),
      );
    } else {
      return _buildDataBaseBookListViewBuilder(snapshot.data!);
    }
  }

  Widget _buildDataBaseBookListViewBuilder(List<Book> booksToDisplay) {
    return ListView.builder(
      itemCount: booksToDisplay.length,
      itemBuilder: (context, index) {
        Book book = booksToDisplay[index];
        bool isSelected = selectedBooks.contains(book);
        return _buildDataBaseBookCard(book, isSelected);
      },
    );
  }

  Widget _buildDataBaseBookCard(Book book, bool isSelected) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: ListTile(
        dense: true,
        leading: _buildBookImage(book.bookImage),
        title: Text(
          book.title,
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${book.numPages} Page',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
            Text(
              'Author: ${book.authors}',
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info),
              tooltip: 'description',
              onPressed: () {
                _showBookDescriptionDialog(book);
              },
            ),
            Checkbox(
              key: Key(book.isbn),
              checkColor: Colors.white,
              fillColor: MaterialStateProperty.resolveWith(getColor),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    selectedBooks.add(book);
                  } else {
                    selectedBooks.remove(book);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Tooltip(
      message: 'Add selected books to the list',
      child: InkWell(
        onTap: () {
          setState(() {
            _addSelectedBooksToList();
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green,
          ),
          child: const Icon(
            Icons.bookmark_added_outlined,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return const Color(0xFF21BFBD);
    }
    return Colors.tealAccent;
  }

  void _addSelectedBooksToList() {
    for (var element in selectedBooks) {
      databaseService.addUserBook(element);
    }
    setState(() {
      selectedBooks.clear();
    });
  }

  void _showBookDescriptionDialog(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(book.title),
          content: Text(book.description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 250,
        fit: BoxFit.fill,
      );
    } else {
      return Image.asset(
        "assets/images/placeholder_image.jpg",
      ); // Replace with your placeholder image asset
    }
  }
}

