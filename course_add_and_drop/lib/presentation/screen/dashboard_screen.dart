import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../components/button_component.dart';
import 'package:flutter/foundation.dart';
import '../../components/add_drop_component.dart' as add_drop_components; // Import custom components
import '../components/button_component.dart' as button; // Import the aliased ButtonComponent
import 'package:course_add_and_drop/main.dart'; // Import main.dart to access global authNotifier

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
  String _username = ''; // Store username
  String? _profilePhoto;
  int _currentHeaderSet = 0; // 0 for Course/Year/Semester (adapted), 1 for Course/Status/Advisor (adapted)

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user profile from API
      final user = await _apiService.getUserProfile();
      debugPrint('User profile fetched: ${user.toJson()}'); // Debug print entire user object
      
      if (!mounted) return;
      setState(() {
        _username = user.username; // Get username from user profile
        _profilePhoto = user.profilePhoto;
        debugPrint('Setting username to: $_username'); // Debug print username
      });

      // Fetch courses and adds
      final courses = await _apiService.getCourses();
      final addsAndDrops = await _apiService.getAdds();

      if (!mounted) return;
      setState(() {
        _courses = courses;
        _adds = addsAndDrops;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('Error fetching user data: $e'); // Debug print error
      if (!mounted) return;

      // If session expired or no token found, immediately redirect to login
      if (e.toString().contains('Session expired') || e.toString().contains('No token found')) {
        _logout();
        return; // Exit the method immediately after redirecting
      }

      // For other errors, set error message and stop loading
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
    try {
      await _apiService.logout();
      // Explicitly update global auth status to false
      authNotifier.value = false; // Use the global authNotifier
      if (!mounted) return;
      debugPrint('Navigating to /login after logout');
      context.go('/login');
    } catch (e) {
      debugPrint('Logout error: $e');
      // Even if API logout fails, clear local data and attempt to navigate
      authNotifier.value = false; // Use the global authNotifier
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString().replaceFirst('Exception: ', '')}. Please try again.')),
      );
      debugPrint('Navigating to /login after logout error');
      context.go('/login');
    }
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
                      GestureDetector(
                        onTap: () {
                          debugPrint('Navigating to /edit-account');
                          context.push('/edit-account');
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profilePhoto != null
                              ? NetworkImage(_profilePhoto!)
                              : const AssetImage('assets/profile.png') as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Welcome, ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _isLoading ? 'Loading...' : _username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // Table Header and Data Container
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey, width: 2),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    // Table Header
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE0E7FF),
                                        border: Border(
                                          bottom: BorderSide(color: Colors.grey, width: 2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Course Name',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Course Code',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Status',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Table Data
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: _adds.length,
                                      itemBuilder: (context, index) {
                                        final add = _adds[index];
                                        final courseTitle = _getCourseTitle(add['course_id']);
                                        final courseCode = _getCourseCode(add['course_id']);
                                        final status = add['approval_status']?.toString().toUpperCase() ?? 'N/A';
                                        final approvalId = add['id']?.toString() ?? 'N/A';

                                        return Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: index == _adds.length - 1 ? Colors.transparent : Colors.grey.shade300,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  courseTitle,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              if (_currentHeaderSet == 0)
                                                Expanded(
                                                  child: Text(
                                                    courseCode,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              else
                                                Expanded(
                                                  child: Text(
                                                    status,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              if (_currentHeaderSet == 0)
                                                Expanded(
                                                  child: Text(
                                                    status,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: status == 'APPROVED' ? Colors.green : 
                                                             status == 'PENDING' ? Colors.orange : 
                                                             status == 'REJECTED' ? Colors.red : Colors.black,
                                                    ),
                                                  ),
                                                )
                                              else
                                                Expanded(
                                                  child: Text(
                                                    approvalId,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Switch View Button (moved outside table)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: Icon(
                                    _currentHeaderSet == 0 ? Icons.arrow_forward : Icons.arrow_back,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _currentHeaderSet = (_currentHeaderSet + 1) % 2;
                                    });
                                  },
                                ),
                              ),
                            ),
                            // Add New Button
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: SizedBox(
                                  width: 260.0,
                                  child: button.ButtonComponent(
                                    value: '+ Add now',
                                    onClick: () {
                                      debugPrint('Navigating to /select-academic-year');
                                      context.go('/select-academic-year');
                                    },
                                    isEnabled: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
          // Footer
          BottomNavigationBar(
            backgroundColor: const Color(0xFF3B82F6),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Courses',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                context.go('/dashboard/user');
              } else {
                context.go('/courses/all');
              }
            },
          ),
        ],
      ),
    );
  }
}