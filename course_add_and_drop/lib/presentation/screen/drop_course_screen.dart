import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:course_add_and_drop/theme/app_colors.dart';
import 'package:course_add_and_drop/components/text.dart' as text;
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/footer_component.dart';

class DropCourseScreen extends StatefulWidget {
  const DropCourseScreen({super.key});

  @override
  State<DropCourseScreen> createState() => _DropCourseScreenState();
}

class _DropCourseScreenState extends State<DropCourseScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _allCourses = [];
  List<Map<String, dynamic>> _filteredCourses = [];
  List<Map<String, dynamic>> _approvedStudentAdds = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedCourse;
  Map<String, dynamic>? _courseToDelete;
  bool _showUpdateDialog = false;
  bool _showDeleteDialog = false;
  String? _userRole;

  // Controllers for the update dialog
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editCodeController = TextEditingController();
  final TextEditingController _editDescriptionController = TextEditingController();
  final TextEditingController _editCreditHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('DropCourseScreen initState called');
    _fetchCoursesAndApprovedAdds();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    setState(() {
      _userRole = role; // Assuming you save role as 'user_role'
      debugPrint('User role loaded in DropCourseScreen: $_userRole (from SharedPreferences: $role)');
    });
  }

  Future<void> _fetchCoursesAndApprovedAdds() async {
    try {
      debugPrint('Starting to fetch all courses and approved adds...');
      final courses = await _apiService.getCourses();
      final addedCourses = await _apiService.getAdds();
      debugPrint('Raw courses data: $courses');
      debugPrint('Raw added courses data: $addedCourses');

      setState(() {
        _allCourses = List<Map<String, dynamic>>.from(courses);
        _filteredCourses = _allCourses;
        _approvedStudentAdds = List<Map<String, dynamic>>.from(addedCourses)
            .where((add) => add['approval_status'] == 'approved')
            .toList();
        _isLoading = false;
      });
      debugPrint('Number of courses received: ${_allCourses.length}');
      debugPrint('Number of approved added courses received: ${_approvedStudentAdds.length}');
    } catch (e) {
      debugPrint('Error fetching courses and approved adds: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        // Check for unauthorized access and redirect to login
        if (e.toString().contains('Unauthorized') || e.toString().contains('No token found')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired or unauthorized. Please log in again.')),
          );
          // Redirect to login screen
          context.go('/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading courses: $e')),
          );
        }
      }
    }
  }

  void _filterCourses(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCourses = _allCourses;
      } else {
        _filteredCourses = _allCourses.where((course) {
          final title = course['title']?.toString().toLowerCase() ?? '';
          final code = course['code']?.toString().toLowerCase() ?? '';
          final description = course['description']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return title.contains(searchLower) || code.contains(searchLower) || description.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _deleteCourse(String courseId) async {
    try {
      await _apiService.deleteCourse(courseId);
      await _fetchCoursesAndApprovedAdds();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting course: $e')),
        );
      }
    }
  }

  Future<void> _updateCourse(String courseId, Map<String, dynamic> updatedData) async {
    try {
      await _apiService.updateCourse(courseId, updatedData);
      await _fetchCoursesAndApprovedAdds();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating course: $e')),
        );
      }
    }
  }

  void _showUpdateCourseDialog(Map<String, dynamic> course) {
    _editTitleController.text = course['title'] ?? '';
    _editCodeController.text = course['code'] ?? '';
    _editDescriptionController.text = course['description'] ?? '';
    _editCreditHoursController.text = course['credit_hours']?.toString() ?? '';

    setState(() {
      _selectedCourse = course;
      _showUpdateDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Update Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editTitleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _editCodeController,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              TextField(
                controller: _editDescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: null,
              ),
              TextField(
                controller: _editCreditHoursController,
                decoration: const InputDecoration(labelText: 'Credit Hours'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showUpdateDialog = false;
                _selectedCourse = null;
              });
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedData = {
                'title': _editTitleController.text.trim(),
                'code': _editCodeController.text.trim(),
                'description': _editDescriptionController.text.trim(),
                'credit_hours': int.tryParse(_editCreditHoursController.text.trim()) ?? 0,
              };
              _updateCourse(course['id'].toString(), updatedData);
              setState(() {
                _showUpdateDialog = false;
                _selectedCourse = null;
              });
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> course) {
    setState(() {
      _courseToDelete = course;
      _showDeleteDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete ${course['title']}?'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showDeleteDialog = false;
                _courseToDelete = null;
              });
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteCourse(course['id'].toString());
              setState(() {
                _showDeleteDialog = false;
                _courseToDelete = null;
              });
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDropConfirmationDialog(Map<String, dynamic> course, Map<String, dynamic> approvedAddEntry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Request Drop Course'),
        content: Text('Are you sure you want to request to drop ${course['title']}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _requestDropCourse(approvedAddEntry['id'], course['title']);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Request Drop', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _requestDropCourse(int addId, String courseTitle) async {
    try {
      await _apiService.dropCourse(addId);
      await _fetchCoursesAndApprovedAdds(); // Refresh both lists
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Drop request for "$courseTitle" submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting drop request: $e')),
        );
      }
    }
  }

  void _handleScreenChange(Screen screen) {
    switch (screen) {
      case Screen.home:
        context.go('/home');
        break;
      case Screen.addCourse:
        context.go('/courses/all');
        break;
      case Screen.dropCourse:
        context.go('/drop-course'); // Already on this screen, but keeping for consistency
        break;
      case Screen.dashboard:
        context.go('/dashboard/user');
        break;
    }
  }

  void _handleBackNavigation() {
    if (_userRole == 'Registrar') {
      context.go('/dashboard/admin');
    } else {
      context.go('/dashboard/user');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DropCourseScreen build method - current user role: $_userRole');
    return Scaffold(
      backgroundColor: AppColors.colorGrayBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 15.0, left: 16.0, right: 16.0, bottom: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: _handleBackNavigation,
                              ),
                              const Text(
                                'Drop Course',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  debugPrint('Navigating to /edit-account');
                                  context.push('/edit-account');
                                },
                                child: const CircleAvatar(
                                  backgroundImage: AssetImage('assets/profile.png'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search courses...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.colorPrimary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterCourses('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.colorPrimary),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: _filterCourses,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_filteredCourses.isEmpty)
                      Expanded(
                        child: Center(
                          child: text.NormalTextComponent(
                            text: _searchQuery.isEmpty
                                ? 'No courses available.'
                                : 'No courses found matching "$_searchQuery".',
                            color: AppColors.colorPrimary,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: _filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = _filteredCourses[index];
                            final approvedAddEntry = _approvedStudentAdds.firstWhere(
                              (add) => add['course_id'] == course['id'],
                              orElse: () => {},
                            );
                            final isDroppable = approvedAddEntry.isNotEmpty &&
                                approvedAddEntry['approval_status'] == 'approved';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: text.HeadingTextComponent(
                                            text: course['title'] ?? 'Untitled Course',
                                            color: AppColors.colorPrimary,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: AppColors.colorPrimary),
                                              onPressed: () {
                                                setState(() {
                                                  _selectedCourse = course;
                                                  _showUpdateDialog = true;
                                                });
                                                _showUpdateCourseDialog(course);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  _courseToDelete = course;
                                                  _showDeleteDialog = true;
                                                });
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Delete Course'),
                                                    content: Text('Are you sure you want to delete ${course['title']}?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _showDeleteDialog = false;
                                                            _courseToDelete = null;
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          _deleteCourse(course['id'].toString());
                                                          setState(() {
                                                            _showDeleteDialog = false;
                                                            _courseToDelete = null;
                                                          });
                                                          Navigator.pop(context);
                                                        },
                                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    text.NormalTextComponent(
                                      text: course['code'] ?? 'No code available',
                                      color: AppColors.colorPrimary,
                                    ),
                                    const SizedBox(height: 8),
                                    text.NormalTextComponent(
                                      text: course['description'] ?? 'No description available',
                                      color: AppColors.colorPrimary,
                                    ),
                                    const SizedBox(height: 8),
                                    text.NormalTextComponent(
                                      text: 'Credit Hours: ${course['credit_hours'] ?? 'N/A'}',
                                      color: AppColors.colorPrimary,
                                    ),
                                    const SizedBox(height: 8),
                                    if (_userRole != 'Registrar')
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          OutlinedButton(
                                            onPressed: isDroppable
                                                ? () => _showDropConfirmationDialog(course, approvedAddEntry)
                                                : null,
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(color: AppColors.colorPrimary),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(isDroppable ? 'Request Drop' : 'Not Droppable'),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            FooterComponent(
              currentScreen: Screen.dropCourse,
              onItemSelected: (screen) {
                switch (screen) {
                  case Screen.home:
                    context.go('/home');
                    break;
                  case Screen.addCourse:
                    context.go('/courses/all');
                    break;
                  case Screen.dropCourse:
                    context.go('/drop-course');
                    break;
                  case Screen.dashboard:
                    context.go('/dashboard/admin');
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _editTitleController.dispose();
    _editCodeController.dispose();
    _editDescriptionController.dispose();
    _editCreditHoursController.dispose();
    super.dispose();
  }
} 
