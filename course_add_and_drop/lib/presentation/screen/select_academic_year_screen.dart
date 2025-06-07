import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart'; // Assuming ApiService is needed here for profile icon/data
import '../../components/button_component.dart' as button;
import '../../components/add_drop_component.dart' as add_drop_components;

class SelectAcademicYearScreen extends StatefulWidget {
  const SelectAcademicYearScreen({super.key});

  @override
  _SelectAcademicYearScreenState createState() => _SelectAcademicYearScreenState();
}

class _SelectAcademicYearScreenState extends State<SelectAcademicYearScreen> {
  String _selectedYear = '';
  String _selectedSemester = '';
  String _addDropSelection = '';

  final List<String> _years = ["2022/2023", "2023/2024", "2024/2025", "2025/2026"];
  final List<String> _semesters = ["One", "Two", "Three"];
  final List<String> _addDropOptions = ["Add", "Drop"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF), // soft blue background
      body: Column(
        children: [
          // Header
          Container(
             width: double.infinity,
             // height: 200, // Adjust height as needed
             padding: const EdgeInsets.only(top: 15.0, left: 16.0, right: 16.0, bottom: 0.0), // Adjusted padding
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     IconButton(
                       icon: const Icon(Icons.arrow_back),
                       onPressed: () => context.pop(),
                     ),
                     const CircleAvatar(
                       // Profile Image Placeholder
                       backgroundImage: AssetImage('assets/profile.png'), // Replace with actual user photo
                     ),
                   ],
                 ),
                 const SizedBox(height: 120), // Spacer
                 Align(
                   alignment: Alignment.center,
                   child: add_drop_components.NormalTextComponent( // Using NormalTextComponent for title
                       value: 'Select Academic Year and Semester'), // Adapted title
                 ),
                 const SizedBox(height: 20), // Spacer
                 // Year Dropdown
                 Align(
                   alignment: Alignment.center,
                   child: Container(
                     width: 260, // Fixed width similar to buttons
                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
                     decoration: BoxDecoration(
                        color: const Color(0xFFEADDDD), // textFieldBgColor
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey), // Add border for clarity
                     ),
                     child: DropdownButtonHideUnderline(
                       child: DropdownButton<String>(
                         isExpanded: true,
                         hint: const Text('Select Year'),
                         value: _selectedYear.isEmpty ? null : _selectedYear,
                         icon: const Icon(Icons.arrow_drop_down),
                         elevation: 16,
                         style: const TextStyle(color: Colors.black87, fontSize: 16),
                         onChanged: (String? newValue) {
                           setState(() {
                             _selectedYear = newValue!;
                           });
                         },
                         items: _years.map<DropdownMenuItem<String>>((String value) {
                           return DropdownMenuItem<String>(
                             value: value,
                             child: Text(value),
                           );
                         }).toList(),
                       ),
                     ),
                   ),
                 ),
                 const SizedBox(height: 25), // Spacer
                 // Semester Dropdown
                 Align(
                   alignment: Alignment.center,
                   child: Container(
                      width: 260, // Fixed width similar to buttons
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEADDDD), // textFieldBgColor
                         borderRadius: BorderRadius.circular(8.0),
                         border: Border.all(color: Colors.grey), // Add border for clarity
                      ),
                     child: DropdownButtonHideUnderline(
                       child: DropdownButton<String>(
                         isExpanded: true,
                         hint: const Text('Select semester'),
                         value: _selectedSemester.isEmpty ? null : _selectedSemester,
                         icon: const Icon(Icons.arrow_drop_down),
                         elevation: 16,
                         style: const TextStyle(color: Colors.black87, fontSize: 16),
                         onChanged: (String? newValue) {
                           setState(() {
                             _selectedSemester = newValue!;
                           });
                         },
                         items: _semesters.map<DropdownMenuItem<String>>((String value) {
                           return DropdownMenuItem<String>(
                             value: value,
                             child: Text(value),
                           );
                         }).toList(),
                       ),
                     ),
                   ),
                 ),
                 const SizedBox(height: 80), // Spacer
                 // Add/Drop Selection
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                       width: 260, // Fixed width similar to buttons
                       padding: const EdgeInsets.symmetric(horizontal: 12.0),
                       decoration: BoxDecoration(
                         color: const Color(0xFFEADDDD), // textFieldBgColor
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey), // Add border for clarity
                       ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Add/Drop'),
                          value: _addDropSelection.isEmpty ? null : _addDropSelection,
                          icon: const Icon(Icons.arrow_drop_down),
                          elevation: 16,
                          style: const TextStyle(color: Colors.black87, fontSize: 16),
                          onChanged: (String? newValue) {
                            setState(() {
                              _addDropSelection = newValue!;
                              if (_addDropSelection == 'Add') {
                                context.go('/courses/all'); // Navigate to Add Course screen
                              } else if (_addDropSelection == 'Drop') {
                                context.go('/drop-course'); // Navigate to Drop Course screen
                              }
                            });
                          },
                          items: _addDropOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
               ],
             ),
           ),
          // CONTENT should take space but not push Footer out
           Expanded(
             child: Container(), // Placeholder for potential future content
           ),
          // Footer at Bottom
           BottomNavigationBar(
            currentIndex: 0, // Adjust index as needed for this screen
            selectedItemColor: const Color(0xFF3B82F6), // Purple color from image
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), // Placeholder icon
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list), // Placeholder icon
                label: 'Courses',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                context.go('/dashboard/user'); // Navigate to user dashboard
              } else if (index == 1) {
                 context.go('/courses/all'); // Assuming this is the courses list screen
              }
            },
          ),
        ],
      ),
    );
  }
} 