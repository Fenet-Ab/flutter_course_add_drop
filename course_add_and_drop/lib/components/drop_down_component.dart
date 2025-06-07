import 'package:flutter/material.dart';

class DropDownComponent extends StatefulWidget {
  final String label;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onValueSelected;
  final Color textFieldBgColor;
  final Color focusedDropdownBg;

  const DropDownComponent({
    Key? key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onValueSelected,
    this.textFieldBgColor = Colors.white,
    this.focusedDropdownBg = const Color(0xFFB1E7DA), // Light cyan
  }) : super(key: key);

  @override
  _DropDownComponentState createState() => _DropDownComponentState();
}

class _DropDownComponentState extends State<DropDownComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: DropdownButtonFormField<String>(
        value: widget.options.contains(widget.selectedValue) ? widget.selectedValue : null,
        onChanged: (value) {
          if (value != null) {
            widget.onValueSelected(value);
          }
        },
        items: widget.options.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: widget.label,
          filled: true,
          fillColor: widget.textFieldBgColor,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue), // Assuming colorPrimary
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white), // Assuming colorTextField
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: const TextStyle(color: Colors.blue), // Assuming colorPrimary
        ),
        icon: const Icon(Icons.arrow_drop_down),
        dropdownColor: widget.focusedDropdownBg,
      ),
    );
  }
}

class DropDownCenteredRowComponent extends StatefulWidget {
  final String label;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onValueSelected;
  final Color focusedDropdownBg;

  const DropDownCenteredRowComponent({
    Key? key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onValueSelected,
    this.focusedDropdownBg = const Color(0xFFE0E0E0), // Assuming colorGrayBackground
  }) : super(key: key);

  @override
  _DropDownCenteredRowComponentState createState() => _DropDownCenteredRowComponentState();
}

class _DropDownCenteredRowComponentState extends State<DropDownCenteredRowComponent> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.blue, // Assuming colorPrimary
                border: Border.all(color: Colors.blue, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.black,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.focusedDropdownBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: widget.options.map((item) {
                  return ListTile(
                    title: Text(item),
                    tileColor: Colors.blue, // Assuming colorPrimary
                    onTap: () {
                      widget.onValueSelected(item);
                      setState(() {
                        _expanded = false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class DropDownEditComponent extends StatefulWidget {
  final String label;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onValueSelected;
  final Color focusedDropdownBg;

  const DropDownEditComponent({
    Key? key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onValueSelected,
    this.focusedDropdownBg = const Color(0xFFE0E0E0), // Assuming colorGrayBackground
  }) : super(key: key);

  @override
  _DropDownEditComponentState createState() => _DropDownEditComponentState();
}

class _DropDownEditComponentState extends State<DropDownEditComponent> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Container(
            height: 40,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white, // Assuming colorTextField
              border: Border.all(color: Colors.white, width: 1), // Assuming colorTextField
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    widget.selectedValue.isEmpty ? widget.label : widget.selectedValue,
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.black,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: widget.focusedDropdownBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: widget.options.map((item) {
                return ListTile(
                  title: Text(item),
                  tileColor: Colors.blue, // Assuming colorPrimary
                  onTap: () {
                    widget.onValueSelected(item);
                    setState(() {
                      _expanded = false;
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}