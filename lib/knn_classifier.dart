import 'dart:math';

import 'book_database.dart';

class Pair<T, U> {
  final T first;
  final U second;

  Pair(this.first, this.second);
}

class KnnClassifier {
  late List<Book> _trainingData;
  final double weightAverageRating = 1.0;
  final double weightRatingsCount = 1.0;
  final double weightTextReviewsCount = 1.0;
  final double weightAuthors = 2.0;
  final double weightGenres = 3.0;
  final double weightDescription = 4.0;
  final double weightNumPages = 1.0;

  KnnClassifier();

  List<Pair<Book, Book>> classifyList(List<Book> trainingData, List<Book> books, int k) {
    _trainingData = trainingData;
    List<Pair<Book, Book>> classifications = [];

    for (var book in books) {
      Book classification = classify(book, k); // Assuming this function returns the recommended book
      classifications.add(Pair(classification,book));
    }

    return classifications;
  }


  Book classify(Book data, int k) {
    final List<Map<String, dynamic>> distances = [];

    for (var trainingPoint in _trainingData) {
      if (data.isbn != trainingPoint.isbn) {
        final double distance = calculateDistance(data, trainingPoint);
        distances.add({'distance': distance, 'target': trainingPoint});
      }
    }

    distances.sort(
            (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    final List<Book> neighbors =
    distances.sublist(0, k).map((e) => e['target'] as Book).toList();

    // Combine information from neighbors
    return combineNeighbors(neighbors);
  }

  Book combineNeighbors(List<Book> neighbors) {
    // Implement a more sophisticated way to combine information from neighbors
    // For now, just return the first neighbor as an example
    return neighbors.isNotEmpty ? neighbors.first : Book.empty();
  }

  double calculateDistance(Book data1, Book data2) {
    double diffAverageRating =
        (data1.averageRating - data2.averageRating) * weightAverageRating;
    double diffAuthors = calculateAuthorDifference(data1.authors, data2.authors) * weightAuthors;
    double diffGenres = calculateGenresDifference(data1.genres, data2.genres) * weightGenres;
    double diffDescription = calculateDescriptionDifference(data1.description, data2.description) * weightDescription;
    double diffNumPages = (data1.numPages - data2.numPages) * weightNumPages;

    double distance = sqrt(pow(diffAverageRating, 2) +
        pow(diffAuthors, 2) +
        pow(diffGenres, 2) +
        pow(diffDescription, 2) +
        pow(diffNumPages, 2));

    return distance;
  }

  List<String> findKeywords(String description, int numKeywords) {
    // Split the description into words
    List<String> words = description.split(' ');

    // Count the frequency of each word
    Map<String, int> wordFrequency = {};
    for (String word in words) {
      word = word.toLowerCase(); // Convert to lowercase for case insensitivity
      wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
    }

    // Sort the words by frequency in descending order
    List<MapEntry<String, int>> sortedWords = wordFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Extract the top numKeywords keywords
    List<String> keywords = [];
    for (int i = 0; i < min(numKeywords, sortedWords.length); i++) {
      keywords.add(sortedWords[i].key);
    }

    return keywords;
  }

  double calculateDescriptionDifference(String desc1, String desc2) {
    List<String> keywords1 = findKeywords(desc1, 5); // Extract top 5 keywords
    List<String> keywords2 = findKeywords(desc2, 5);

    Set<String> set1 = keywords1.toSet();
    Set<String> set2 = keywords2.toSet();

    double intersectionSize = set1.intersection(set2).length.toDouble();
    double unionSize = set1.union(set2).length.toDouble();

    return 1.0 - (intersectionSize / unionSize);
  }

  double calculateAuthorDifference(String author1, String author2) {
    return (author1 == author2) ? 0.0 : 2.0;
  }

  double calculateGenresDifference(String genres1, String genres2) {
    // Split the genre strings into sets of genres
    Set<String> set1 = genres1.split(',').map((genre) => genre.trim()).toSet();
    Set<String> set2 = genres2.split(',').map((genre) => genre.trim()).toSet();

    // Compute the intersection and union sizes of the genre sets
    double intersectionSize = set1.intersection(set2).length.toDouble();
    double unionSize = set1.union(set2).length.toDouble();

    // Calculate the Jaccard similarity coefficient
    double similarity = intersectionSize / unionSize;

    // Return the difference (1 - similarity) to represent dissimilarity
    return 1.0 - similarity;
  }

}
