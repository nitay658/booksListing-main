import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:books_app/book_database.dart';

import 'addBookPage.dart';

class SecondPage extends StatefulWidget {
  final String userEmail;

  const SecondPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<Book> _booksToRead = [];
  late final List<Book> _allBooks = [];
  List<Book> searchResults = [];
  late StreamController<List<Book>> _searchController;
  late StreamController<List<Book>> _databaseSearchController;
  late bool _localResultsEmpty;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController = BehaviorSubject<List<Book>>.seeded([]);
    _databaseSearchController = BehaviorSubject<List<Book>>.seeded([]);
    _getToReadBooks();
    _localResultsEmpty = false;
    _textEditingController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onSearchTextChanged);
    _searchController.close();
    _databaseSearchController.close();
    _textEditingController.dispose();
    super.dispose();
  }

  _onSearchTextChanged() {
    String searchText = _textEditingController.text.toLowerCase();

    List<Book> localResults = _booksToRead
        .where((book) =>
        book.title.toLowerCase().contains(searchText) ||
        book.description.toLowerCase().contains(searchText) ||
        book.authors.toLowerCase().contains(searchText))
        .toList();

    if (localResults.isEmpty) {
      // Fetch results from the database based on the search text
      List<Book> filteredDatabaseBooks = _allBooks
          .where((book) => book.title.toLowerCase().contains(searchText))
          .toList();
      _localResultsEmpty = true;
      setState(() {
        searchResults = List.from(filteredDatabaseBooks);
        _databaseSearchController.add(searchResults);
      });
    } else {
      // Use local results if available
      _localResultsEmpty = false;
      setState(() {
        searchResults = List.from(localResults);
        _searchController.add(searchResults);
      });
    }
  }

  _getToReadBooks() async {
    var lst = DatabaseService.getInstance(userEmail: widget.userEmail).getBooksToRead();
    var allbookslst = DatabaseService.getInstance(userEmail: widget.userEmail).getAllBooks();
    //DatabaseService.getInstance(userEmail: widget.userEmail).updateBooksCollection();
    allbookslst.listen((List<Book> run) { setState(() {
      _allBooks.addAll(run);
    });
    });
    lst.listen((List<Book> run) {
      setState(() {
        _booksToRead = [];
        _booksToRead.addAll(run);
        searchResults = List.from(_booksToRead);
        _searchController.add(searchResults);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF21BFBD),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 25.0),
          const Padding(
            padding: EdgeInsets.only(left: 40.0),
            child: Row(
              children: <Widget>[
                Text('Your',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0)),
                SizedBox(width: 10.0),
                Text('Favourites Books',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 25.0)),],
            ),
          ),
          AppBar(
            backgroundColor: const Color(0xFF21BFBD),
            title: CupertinoSearchTextField(
              backgroundColor: Colors.white,
              controller: _textEditingController,
              onChanged: (text) => _onSearchTextChanged(),
            ),
            titleTextStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            centerTitle: true,
            elevation: 0,
          ),
          _buildBookList(),

        ],
      ),
    );
  }

  Widget _buildBookList() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF21BFBD),
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
      child: Column(children: <Widget>[Stack(
        alignment: Alignment.bottomLeft,
        children: [
          //const SizedBox(height: 40.0),
          if (!_localResultsEmpty) _buildMyListContainer()
          else _buildDataBaseContainer(),
          _buildAddBookButton(),
        ],
      )],),
    );
  }

  Widget _buildDataBaseContainer() {
    return Container(
      height: MediaQuery.of(context).size.height - 260.0,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF21BFBD),
          style: BorderStyle.solid,
          width: 1.0,),
        color: Colors.grey,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(75.0)),
      ),
      child: StreamBuilder<List<Book>>(
        stream: _databaseSearchController.stream,
        builder: (context, snapshot) {
          return _buildBookListView(context, snapshot, true);
        },
      ),
    );
  }


  Widget _buildMyListContainer() {
    return Container(
      height: MediaQuery.of(context).size.height - 260.0,
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF21BFBD),
        style: BorderStyle.solid,
        width: 1.0,),
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(75.0)),
      ),
      child: StreamBuilder<List<Book>>(
        stream: _searchController.stream,
        builder: (context, snapshot) {
          return _buildBookListView(context, snapshot,false);
        },
      ),
    );
  }
  Widget _buildBookListView(BuildContext context, AsyncSnapshot<List<Book>> snapshot,bool  isFromDatabase) {
    if (snapshot.connectionState == ConnectionState.active ||
        snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Center(
          child: Text('Error: ${snapshot.error}'),
        );
      } else if (snapshot.hasData) {
        List<Book> booksToRead = snapshot.data!;
        return ListView.builder(
          itemCount: booksToRead.length,
          itemBuilder: (context, index) {
            Book book = booksToRead[index];
            return _buildBookListItem(book,isFromDatabase);
          },
        );
      } else {
        return const Center(
          child: Text('No books available.'),
        );
      }
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _buildBookListItem(Book book,bool isFromDatabase) {
    return GestureDetector(onTap: (){_showReviewPopup(context, book);},child:Card(
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
        subtitle: _buildBookSubtitle(book),
        trailing: _buildBookActions(book,isFromDatabase),
      ),
    ));
  }

  Widget _buildBookSubtitle(Book book) {
    return Column(
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
    );
  }

  Widget _buildBookActions(Book book, bool isFromDatabase) {
    if (isFromDatabase) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addBookToList(book);
            },
            tooltip: 'Add to your list',
          ),
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: 'Description',
            onPressed: () {
              _showBookDescriptionDialog(book);
            },
          ),
        ],
      );
    } else {
      // For books from the user's personal list
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              _removeBook(book);
            },
            tooltip: 'Remove book',
          ),
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: 'Description',
            onPressed: () {
              _showBookDescriptionDialog(book);
            },
          ),
        ],
      );
    }
  }

  void _showReviewPopup(BuildContext context, Book book) {
    TextEditingController reviewController = TextEditingController();
    double rating = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Review ${book.title}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Write your review here:'),
                TextField(
                  controller: reviewController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your review',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Rate the book:'),
                // Add star rating widget
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 30,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (newRating) {
                    rating = newRating;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save the review
                String review = reviewController.text;
                if (review.isNotEmpty) {
                  // Create UserReview object
                  UserReview userReview = UserReview(
                    userId: widget.userEmail, // Replace with actual user ID
                    rating: rating,
                    comment: review,
                    timestamp: DateTime.now(),
                  );
                  DatabaseService.getInstance(userEmail: widget.userEmail).addReview(book.isbn, userReview);
                  Navigator.of(context).pop();
                } else {
                  // Show error message or handle empty review
                }
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }


  void _addBookToList(Book book) {
    // Implement the logic to add the book to the user's personal list
    // You can call DatabaseServer.addUserBook(book) or any other relevant method
    DatabaseService.getInstance(userEmail: widget.userEmail).addUserBook(book);

    // Optionally, you can update the local state to reflect the change
    setState(() {
      _booksToRead.add(book);
    });
  }


  void _removeBook(Book book) {
    setState(() {
      _booksToRead.remove(book);
      DatabaseService.getInstance(userEmail: widget.userEmail).removeUserBook(book);
    });
  }

  Widget _buildAddBookButton() {
    return Positioned(
      //bottom: 10.0,
      left: 16.0,
      child: InkWell(
        onTap: () {
          _navigateToAddBookPage();
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF21BFBD),
          ),
          child: const IconButton(tooltip: 'Add favourites books',
            color: Colors.white, onPressed: null, icon: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _navigateToAddBookPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookPage(
          userEmail: widget.userEmail,
        ),
      ),
    );
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
      );
    }
  }

}