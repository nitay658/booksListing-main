import 'package:flutter/material.dart';
import 'multi_select.dart'; // Import your custom MultiSelect widget
import 'book_database.dart';

class AddBookToDataBasePage extends StatefulWidget {
  final String userEmail;

  const AddBookToDataBasePage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<AddBookToDataBasePage> createState() => _AddBookToDataBasePageState();
}

class _AddBookToDataBasePageState extends State<AddBookToDataBasePage> {
  late String userEmail;
  late DatabaseService databaseService;
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _averageRatingController = TextEditingController();
  final TextEditingController _numPagesController = TextEditingController();
  final TextEditingController _publicationDateController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  late String _selectedGenres ="Fantasy";

  final List<String> availableGenres = [
    'Fantasy',
    'Science Fiction',
    'Dystopian',
    'Action & Adventure',
    'Mystery',
    'Horror',
    'Thriller & Suspense',
    'Historical Fiction',
    'Romance',
    'Women’s Fiction',
    'Contemporary Fiction',
    'Graphic Novel',
    'Short Story',
    'Young Adult',
    'New Adult',
    'Children’s',
    'Biography',
    'Food & Drink',
    'Art & Photography',
    'History',
    'Self-help',
    'Travel',
    'True Crime',
    'Humor',
    'Science & Technology',
  ];

  @override
  void initState() {
    super.initState();
    userEmail = widget.userEmail;
    databaseService = DatabaseService.getInstance(userEmail: userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book to Database'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(_isbnController, 'ISBN'),
              buildTextField(_titleController, 'Title'),
              buildTextField(_descriptionController, 'Description'),
              buildTextField(_authorController, 'Author'),
              buildTextField(_imageController, 'Book Image URL'),
              buildNumericTextField(_averageRatingController, 'Average Rating'),
              buildNumericTextField(_numPagesController, 'Number of Pages'),
              buildTextField(_publicationDateController, 'Publication Date'),
              buildGenreDropdownButton(),
              buildTextField(_urlController, 'Goodreads URL'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (validateForm()) {
                    Book newBook = Book(
                      isbn: _isbnController.text,
                      title: _titleController.text,
                      authors: _authorController.text,
                      description: _descriptionController.text,
                      averageRating: double.parse(_averageRatingController.text),
                      numPages: int.parse(_numPagesController.text),
                      genres: _selectedGenres,
                      publication_date: int.parse(_publicationDateController.text),
                      bookImage: _imageController.text,
                      //url: _urlController.text,
                    );

                    databaseService.addBook(newBook);

                    clearFormFields();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Book added successfully'),
                      ),
                    );
                  }
                },
                child: const Text('Add Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildNumericTextField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget buildGenreDropdownButton() {
    return GestureDetector(
      onTap: () async {
        final List<String>? results = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return MultiSelect(items: availableGenres);
          },
        );

        // Update UI
        if (results != null) {
          setState(() {
            _selectedGenres = results.toString();
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Genres',
          border: OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedGenres, // Display selected genres
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  bool validateForm() {
    for (var controller in [
      _isbnController,
      _titleController,
      _descriptionController,
      _authorController,
      _imageController,
      _averageRatingController,
      _numPagesController,
      _publicationDateController,
      _urlController,
    ]) {
      if (controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all the fields'),
          ),
        );
        return false;
      }
    }

    for (var controller in [
      _averageRatingController,
      _numPagesController,
      _publicationDateController,
    ]) {
      try {
        double.parse(controller.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid numeric input'),
          ),
        );
        return false;
      }
    }

    if (_selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one genre'),
        ),
      );
      return false;
    }

    return true;
  }

  void clearFormFields() {
    _isbnController.clear();
    _titleController.clear();
    _descriptionController.clear();
    _authorController.clear();
    _imageController.clear();
    _averageRatingController.clear();
    _numPagesController.clear();
    _publicationDateController.clear();
    _urlController.clear();
    _selectedGenres = ""; // Reset selected genres
  }
}
