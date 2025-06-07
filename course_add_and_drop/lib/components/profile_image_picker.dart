import 'package:flutter/material.dart';

// Assuming Screen enum from previous conversions
enum Screen {
  HomeScreen,
  AddCourse,
  DropCourse,
  UserDashboardScreen,
  AdminDashboard,
  SelectAcademicYear,
  EditProfile, // Added for navigation
}

// Reusing NormalTextComponent from previous conversions
class NormalTextComponent extends StatelessWidget {
  final String value;

  const NormalTextComponent({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Reusing DropDownEditComponent from previous conversions
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

class ProfileImagePlaceholder extends StatelessWidget {
  final BoxConstraints? constraints;
  final VoidCallback onClick;

  const ProfileImagePlaceholder({
    Key? key,
    this.constraints,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onClick,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 60,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const NormalTextComponent(value: 'Welcome'), // Assuming R.string.welcomef
      ],
    );
  }
}

class ProfileImgPlaceholder extends StatelessWidget {
  final BoxConstraints? constraints;
  final VoidCallback onClick;

  const ProfileImgPlaceholder({
    Key? key,
    this.constraints,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 25, top: 10),
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 30, // Adjusted to fit smaller container
          ),
        ),
      ),
    );
  }
}

class ProfileEditPlaceholder extends StatefulWidget {
  final BoxConstraints? constraints;
  final VoidCallback onClick;

  const ProfileEditPlaceholder({
    Key? key,
    this.constraints,
    required this.onClick,
  }) : super(key: key);

  @override
  _ProfileEditPlaceholderState createState() => _ProfileEditPlaceholderState();
}

class _ProfileEditPlaceholderState extends State<ProfileEditPlaceholder> {
  String _selected = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(right: 25, top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: widget.onClick,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 10),
          DropDownEditComponent(
            label: _selected.isEmpty ? 'Edit/Logout' : _selected,
            options: const ['Edit', 'Logout'],
            selectedValue: _selected,
            onValueSelected: (value) {
              setState(() {
                _selected = value;
              });
            },
          ),
        ],
      ),
    );
  }
}