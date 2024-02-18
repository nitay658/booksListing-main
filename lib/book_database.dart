import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class Book {
  final String isbn; // Add the ISBN field if it's part of your data
  final String title;
  final String description;
  final String authors;
  final double averageRating;
  final int numPages;
  final String genres;
  final int publication_date;
  final String bookImage;
  //final String url;

  Book({
    required this.isbn,
    required this.title,
    required this.description,
    required this.authors,
    required this.averageRating,
    required this.numPages,
    required this.publication_date,
    required this.bookImage,
    required this.genres,
    //required this.url
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Book(
      isbn: data['isbn'] ?? '', // Add the ISBN field if it's part of your data
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      authors: data['authors'] ?? '',
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      numPages: data['numPages'] ?? 0,
      publication_date: data['publication_date'] ?? 0,
      bookImage: data['bookImage'] ?? '',
      genres: data['genres'] ?? '',
      //url: data['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isbn': isbn,
      'title': title,
      'description': description,
      'authors': authors,
      'averageRating': averageRating,
      'numPages': numPages,
      'genres': genres,
      'publication_date': publication_date,
      'bookImage': bookImage,
      //'url': url,
    };
  }

  static empty() {
    return Book(
      isbn: '',
      title: '',
      description: '',
      authors: '',
      averageRating: 0.0,
      numPages: 0,
      genres: "",
      publication_date: 1950,
      bookImage: '',
      //url: '',
    );
  }
}

Set<String> fieldList() {
  return {
    'isbn', // Add the ISBN field if it's part of your data
    'title',
    'description', // Updated from 'authors' to 'description'
    'averageRating', // Updated from 'average_rating'
    'numPages', // Updated from 'num_of_pages'
    'genres', // Added genres
    'publication_date',
    'bookImage', // Updated from 'book_image'
    //'url',
  };
}


class DatabaseService {
  final String userEmail;
  bool flag = true;

  DatabaseService._({required this.userEmail});

  // Static variable to hold the single instance of the class
  static DatabaseService? _instance;

  // Static method to access the single instance of the class
  static DatabaseService getInstance({required String userEmail}) {
    // Create a new instance if it doesn't exist
    _instance ??= DatabaseService._(userEmail: userEmail);
    return _instance!;
  }

  final CollectionReference booksCollection =
      FirebaseFirestore.instance.collection('books');
  final CollectionReference userBooksCollection =
      FirebaseFirestore.instance.collection('user-book');


  Future<void> addUserBook(Book book) async {
    await userBooksCollection
        .doc(userEmail)
        .collection('books-to-read')
        .doc(book.isbn)
        .set(book.toMap());
  }

  Future<void> removeUserBook(Book book) async {
    // Remove the book from Firestore
    await userBooksCollection
        .doc(userEmail)
        .collection('books-to-read')
        .doc(book.isbn)
        .delete();
  }

  Future<void> addBook(Book book) async {
    await booksCollection.doc(book.isbn).set(book.toMap());
  }

  Future<void> markBookAsRead(Book book) async {
    await userBooksCollection
        .doc(userEmail)
        .collection('books-read')
        .doc(book.isbn)
        .set(book.toMap());
  }

  Stream<List<Book>> getBooksToRead() {
    return userBooksCollection
        .doc(userEmail)
        .collection('books-to-read')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  Stream<List<Book>> getBooksRead() {
    return userBooksCollection
        .doc(userEmail)
        .collection('books-read')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  Stream<List<Book>> getAllBooks() {
    return booksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  Future<void> insertBooks() async {
    if (flag) {
      var data = await rootBundle.loadString('assets/data - data.csv.csv');

      List<List<dynamic>> database = const CsvToListConverter().convert(data);

      int rowsToShow = database.length;
      print("rowsToShow: $rowsToShow");
      for (int i = 1; i < rowsToShow; i++) {
        String isbn = database[i][0].toString();
        String title = database[i][2].toString();
        String description = database[i][7].toString();
        String authors = database[i][4].toString();
        double averageRating = database[i][9].toDouble(); // (data['averageRating'] ?? 0.0).toDouble()
        int publication_date = database[i][8];
        String bookImage = database[i][6].toString();
        String genres = database[i][5].toString();
        int numPages = database[i][10];
        // print('ISBN: $isbn');
        // print('Title: $title');
        // print('Description: $description');
        // print('Authors: $authors');
        // print('Average Rating: $averageRating');
        // print('Publication Date: $publication_date');
        // print('Book Image: $bookImage');
        // print('Genres: $genres');
        // print('numPages: $numPages');
        print("i:   $i");
        if(isbn != "" && title != "" && description != "" && authors != "" && averageRating != 0.0 && bookImage != "" && genres != "" && publication_date != -1 && bookImage != "") {
          Book book = Book(
              isbn: isbn,
              title: title,
              description: description,
              authors: authors,
              averageRating: averageRating,
              numPages: numPages,
              publication_date: publication_date,
              bookImage: bookImage,
              genres: genres,
          );
          print(book.toMap().toString());
          addBook(book);
        }
      }
      flag = false;
    }
  }



  // final String isbn; // Add the ISBN field if it's part of your data
  // final String title;
  // final String description;
  // final String authors;
  // final double averageRating;
  // final int numPages;
  // final List<String> genres;
  // final int publication_date;
  // final String bookImage;
  // final String url;
  // Book({
  //   required this.isbn,
  //   required this.title,
  //   required this.description,
  //   required this.authors,
  //   required this.averageRating,
  //   required this.numPages,
  //   required this.publication_date,
  //   required this.bookImage,
  //   required this.genres,
  //   required this.url
  // });


  Future<Function> crossover_int(List<List<dynamic>> BX_Books) async {
    int rowsToShow = BX_Books.length;
    int fun(String name, int index) {
      for (int i = 1; i < rowsToShow; i++) {
        if (BX_Books[i][1] == name) {
          return BX_Books[i][index];
        }
      }
      return -1;
    }
    return Future.value(fun);
  }
  Future<Function> crossover_String(List<List<dynamic>> BX_Books) async {
    int rowsToShow = BX_Books.length;
    String fun(String name, int index) {
      for (int i = 1; i < rowsToShow; i++) {
        if (BX_Books[i][1] == name) {
          return BX_Books[i][index];
        }
      }
      return "";
    }
    return Future.value(fun);
  }
  Future<Function> crossover_StringList(List<List<dynamic>> BX_Books) async {
    int rowsToShow = BX_Books.length;
    List<String> fun(String name, int index) {
      for (int i = 1; i < rowsToShow; i++) {
        if (BX_Books[i][1] == name) {
          return BX_Books[i][index];
        }
      }
      return [""];
    }
    return Future.value(fun);
  }
}
