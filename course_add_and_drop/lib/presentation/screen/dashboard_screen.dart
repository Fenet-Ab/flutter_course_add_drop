import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../components/button_component.dart';
import 'package:flutter/foundation.dart';
import '../../components/add_drop_component.dart' as add_drop_components; // Import custom components
import '../components/button_component.dart' as button; // Import the aliased ButtonComponent

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _adds = []; // Includes both adds and drops now
  bool _isLoading = true;
  String? _errorMessage;
  String _userName = '';
  int _currentHeaderSet = 0; // 0 for Course/Year/Semester (adapted), 1 for Course/Status/Advisor (adapted)

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final user = await _apiService.getUserProfile();
      if (!mounted) return;
      setState(() {
        _userName = user.fullName;
      });

      final courses = await _apiService.getCourses();
      // Assuming getAdds now returns both adds and drops for the user
      final addsAndDrops = await _apiService.getAdds(); // This needs to also fetch drops

      if (!mounted) return;
      setState(() {
        _courses = courses;
        _adds = addsAndDrops; // Store all adds and drops here
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Helper to get course title from courseId
  String _getCourseTitle(int courseId) {
    final course = _courses.firstWhere(
      (c) => c['id'] == courseId,
      orElse: () => {},
    );
    return course.isNotEmpty ? course['title'] ?? 'N/A' : 'N/A';
  }

    // Helper to get course code from courseId
  String _getCourseCode(int courseId) {
    final course = _courses.firstWhere(
      (c) => c['id'] == courseId,
      orElse: () => {},
    );
    return course.isNotEmpty ? course['code'] ?? 'N/A' : 'N/A';
  }


  Future<void> _logout() async {
    await _apiService.logout();
    if (!mounted) return;
    debugPrint('Navigating to /login');
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 200,
            color: const Color(0xFF3B82F6),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _logout,
                  padding: const EdgeInsets.only(top: 15),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/profile.png'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                    : Column(
                        children: [
                          // Switchable Table View
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 20.0), // Add horizontal and top padding here
                              child: Column(
                                children: [
                                  // Header Row
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    decoration: BoxDecoration(
                                       color: const Color(0xFFE0E7FF), // soft blue background
                                       border: Border.all(color: Colors.grey, width: 2),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(child: Text('Course Name', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                                        if (_currentHeaderSet == 0)
                                          Expanded(child: Text('Course Code', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)))
                                        else
                                          Expanded(child: Text('Status', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                                        if (_currentHeaderSet == 0)
                                           Expanded(child: Text('Status', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)))
                                        else
                                           Expanded(child: Text('Approval ID', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                                      ],
                                    ),
                                  ),
                                  // Data Rows
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                         border: Border.all(color: Colors.grey, width: 2),
                                         color: Colors.white,
                                      ),
                                      child: ListView.builder(
                                        itemCount: _adds.length,
                                        itemBuilder: (context, index) {
                                          final add = _adds[index];
                                          final courseTitle = _getCourseTitle(add['course_id']);
                                          final courseCode = _getCourseCode(add['course_id']);
                                          final status = add['approval_status']?.toString().toUpperCase() ?? 'N/A';
                                          final approvalId = add['id']?.toString() ?? 'N/A';

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(child: Text(courseTitle, textAlign: TextAlign.center)),
                                                if (_currentHeaderSet == 0)
                                                  Expanded(child: Text(courseCode, textAlign: TextAlign.center))
                                                else
                                                  Expanded(child: Text(status, textAlign: TextAlign.center)),
                                                if (_currentHeaderSet == 0)
                                                  Expanded(child: Text(status, textAlign: TextAlign.center))
                                                 else
                                                  Expanded(child: Text(approvalId, textAlign: TextAlign.center)),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Switch View Button
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      icon: Icon(
                                        _currentHeaderSet == 0 ? Icons.arrow_forward : Icons.arrow_back,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _currentHeaderSet = (_currentHeaderSet + 1) % 2;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Add New Button below the table (moved outside Expanded)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0), // Vertical padding
                            child: Center(
                              child: SizedBox( // Explicitly setting width to ensure it respects centering
                                width: 260.0, // Fixed width as per other buttons
                                child: button.ButtonComponent( // Use the aliased custom ButtonComponent
                                  value: '+ Add now', // Or the appropriate text for this button
                                  onClick: () {
                                     debugPrint('Navigating to /select-academic-year');
                                     context.go('/select-academic-year'); // Navigate to the new screen
                                   },
                                isEnabled: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
            // Footer
            BottomNavigationBar(
              backgroundColor: const Color(0xFF3B82F6),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
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
                  context.go('/dashboard/user');
                } else {
                  context.go('/courses/all'); // Assuming this is the courses list screen
                }
              },
            ),
          ],
        ),
      );
    
  }
}