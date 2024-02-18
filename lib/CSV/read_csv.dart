import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel Reader App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: YourExcelReaderWidget(),
    );
  }
}

class YourExcelReaderWidget extends StatefulWidget {
  @override
  _YourExcelReaderWidgetState createState() => _YourExcelReaderWidgetState();
}

class _YourExcelReaderWidgetState extends State<YourExcelReaderWidget> {
  List<List<String>> excelData = [];

  @override
  void initState() {
    super.initState();
    _loadExcel();
  }

  Future<void> _loadExcel() async {
    try {
      var file = 'books_data/goodreads_data.xlsx';
      var bytes = File(file).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        print(table); //sheet Name
        print(excel.tables[table]!.maxColumns);
        print(excel.tables[table]!.maxRows);
        for (var row in excel.tables[table]!.rows) {
          setState(() {
            excelData.add(List<String>.from(row));
          });
        }
      }
    } catch (e) {
      // Handle the error, e.g., show an error message
      print('Failed to load Excel. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel Reader App'),
      ),
      body: excelData.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: excelData.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(excelData[index].join(' | ')),
          );
        },
      ),
    );
  }
}
