// multi_select.dart
import 'package:flutter/material.dart';
//import 'package:multi_select_flutter/multi_select_flutter.dart';

class MultiSelect extends StatefulWidget {
  final List<String> items;
  MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  final List<String> _selectedItems = [];

  void _itemChange(String itemValue, bool isSelected) {
    if (itemValue != null) {
      setState(() {
        if (isSelected) {
          _selectedItems.add(itemValue);
        } else {
          _selectedItems.remove(itemValue);
        }
      });
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    if (_selectedItems.isNotEmpty) {
      Navigator.pop(context, _selectedItems);
    } else {
      // Provide feedback to the user that at least one item should be selected.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Genres'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
            value: _selectedItems.contains(item),
            title: Text(item),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (isChecked) => _itemChange(item, isChecked!),
          ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Select'),
        ),
      ],
    );
  }
}
