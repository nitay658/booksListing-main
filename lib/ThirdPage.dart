import 'package:flutter/material.dart';
import 'book_database.dart';
import 'knn_classifier.dart';

class ThirdPage extends StatefulWidget {
  final String userEmail;
  const ThirdPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  late DatabaseService databaseService;
  List<Book> _booksToRead = [];
  List<Book> _allBooks = [];
  List<Pair<Book, Book>> _recommendedBooks = [];
  bool _mounted = false;

  @override
  void initState() {
    super.initState();
    _mounted = true;
    databaseService = DatabaseService.getInstance(userEmail: widget.userEmail);
    classifyReadBooks();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
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
                Text('Recommendation',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0)),
                SizedBox(width: 10.0),
                Text('System',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontSize: 25.0))
              ],
            ),
          ),
          Container(
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
                    stream: databaseService.getBooksRead(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active ||
                          snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          //List<Book> booksToRead = snapshot.data!;
                          return ListView.builder(
                            itemCount: _recommendedBooks.length,
                            itemBuilder: (context, index) {
                              Book book = _recommendedBooks[index].first;
                              String based_recommendtion = _recommendedBooks[index].second.title;
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
                                      ),Text(
                                        'based on the book: $based_recommendtion',
                                        style: const TextStyle(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
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
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void classifyReadBooks() {
    var readBooksStream = databaseService.getBooksToRead();
    var allBooksStream = databaseService.getAllBooks();

    readBooksStream.listen((List<Book> run) {
      if (_mounted) {
        setState(() {
          _booksToRead = run;
        });
      }
    });

    allBooksStream.listen((List<Book> run) {
      if (_mounted) {
        setState(() {
          _allBooks = run;
          // Classify and update recommended books
          _recommendedBooks = classifyAndRecommend();
        });
      }
    });
  }

  List<Pair<Book, Book>> classifyAndRecommend() {
    KnnClassifier knnClassifier = KnnClassifier();
    return knnClassifier.classifyList(_allBooks, _booksToRead, 5);
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
