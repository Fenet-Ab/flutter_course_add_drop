import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final String query;
  final ValueChanged<String> onQueryChange;
  final BoxConstraints? constraints;

  const SearchBar({
    Key? key,
    required this.query,
    required this.onQueryChange,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        constraints: constraints ?? const BoxConstraints(maxHeight: 50),
        child: TextField(
          controller: TextEditingController(text: query),
          onChanged: onQueryChange,
          decoration: InputDecoration(
            hintText: 'Search courses...',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
            filled: true,
            fillColor: Colors.white, // Assuming white
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue), // Assuming colorPrimary
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white), // Assuming white
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          ),
          maxLines: 1,
          cursorColor: Colors.white, // Assuming white
        ),
      ),
    );
  }
}