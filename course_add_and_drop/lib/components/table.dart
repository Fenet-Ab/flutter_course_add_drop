import 'package:flutter/material.dart';

// Assuming Screen enum from previous conversions
enum Screen {
  HomeScreen,
  AddCourse,
  DropCourse,
  UserDashboardScreen,
  AdminDashboard,
  SelectAcademicYear, // Added for navigation
}

class SwitchableTableView extends StatefulWidget {
  final VoidCallback onNavigateToSelectAcademicYear;

  const SwitchableTableView({
    Key? key,
    required this.onNavigateToSelectAcademicYear,
  }) : super(key: key);

  @override
  _SwitchableTableViewState createState() => _SwitchableTableViewState();
}

class _SwitchableTableViewState extends State<SwitchableTableView> {
  int _currentHeaderSet = 0; // 0: first set, 1: second set

  final List<(String, String, String)> tableData = [
    ('Mobile Dev', '2024', '2nd'),
    ('AI', '2023', '1st'),
    ('Web Dev', '2022', '1st'),
  ];

  final List<(String, String, String)> statusData = [
    ('Mobile Dev', 'Approved', 'Dr. Fikru'),
    ('AI', 'Pending', 'Dr. Eleni'),
    ('Web Dev', 'Rejected', 'Dr. Abdi'),
  ];

  @override
  Widget build(BuildContext context) {
    final displayData = _currentHeaderSet == 0 ? tableData : statusData;

    return Container(
      color: const Color(0xFFE6ECFF), // Soft blue
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0), // Assuming colorGrayBackground
              border: Border.all(color: Colors.grey, width: 2),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Expanded(
                  child: Text(
                    'Course Name',
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_currentHeaderSet == 0) ...[
                  const Expanded(
                    child: Text(
                      'Academic Year',
                      style: TextStyle(color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Semester',
                      style: TextStyle(color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else ...[
                  const Expanded(
                    child: Text(
                      'Status',
                      style: TextStyle(color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Advisor',
                      style: TextStyle(color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Data Rows
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 2),
            ),
            child: ListView.builder(
              itemCount: displayData.length,
              itemBuilder: (context, index) {
                final item = displayData[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: Text(item.$1, textAlign: TextAlign.center)),
                      Expanded(child: Text(item.$2, textAlign: TextAlign.center)),
                      Expanded(child: Text(item.$3, textAlign: TextAlign.center)),
                    ],
                  ),
                );
              },
            ),
          ),
          // Switch View Button
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentHeaderSet = (_currentHeaderSet + 1) % 2;
                  });
                },
                icon: Icon(
                  _currentHeaderSet == 0 ? Icons.arrow_forward : Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          // Dashboard Button (reusing ButtonComponent from previous conversions)
          ButtonComponent(
            value: 'Go to Dashboard', // Assuming R.string.dashboard_button
            onClick: widget.onNavigateToSelectAcademicYear,
            enabled: true,
          ),
        ],
      ),
    );
  }
}

// Reusing ButtonComponent from previous conversions
class ButtonComponent extends StatelessWidget {
  final String value;
  final VoidCallback onClick;
  final bool enabled;

  const ButtonComponent({
    Key? key,
    required this.value,
    required this.onClick,
    required this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: enabled ? onClick : null,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(260, 50),
          backgroundColor: enabled ? Colors.blue : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}