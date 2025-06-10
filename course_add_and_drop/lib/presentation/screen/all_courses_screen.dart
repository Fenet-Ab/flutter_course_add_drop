import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../components/course_card_component.dart';
import '../../components/text_field.dart' as text_field;
import '../../components/footer_component.dart';
import 'package:course_add_and_drop/theme/app_colors.dart';
import 'package:course_add_and_drop/components/text.dart' as text;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllCoursesScreen extends StatefulWidget {
  const AllCoursesScreen({super.key});

  @override
  State<AllCoursesScreen> createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _filteredCourses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _errorMessage;
  Map<String, dynamic>? _selectedCourse;
  bool _showUpdateDialog = false;
  bool _showDeleteDialog = false;
  Map<String, dynamic>? _courseToDelete;
  String? _userRole;

  // Controllers for the update dialog
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editCodeController = TextEditingController();
  final TextEditingController _editDescriptionController = TextEditingController();
  final TextEditingController _editCreditHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchCourses();
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

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role');
    });
  }

  Future<void> _fetchCourses() async {
    try {
      final courses = await _apiService.getCourses();
      setState(() {
        _courses = List<Map<String, dynamic>>.from(courses);
        _filteredCourses = _courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
      }
    }
  }

  void _filterCourses(String value) {
    setState(() {
      _searchQuery = value;
      if (value.isEmpty) {
        _filteredCourses = _courses;
      } else {
        _filteredCourses = _courses.where((course) {
          final title = course['title']?.toString().toLowerCase() ?? '';
          final code = course['code']?.toString().toLowerCase() ?? '';
          final description = course['description']?.toString().toLowerCase() ?? '';
          final searchLower = value.toLowerCase();
          return title.contains(searchLower) || code.contains(searchLower) || description.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _addCourse(int courseId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Course'),
        content: Text('Are you sure you want to add this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Adding course...')),
              );
              try {
                await _apiService.addCourse(courseId);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course added successfully!')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding course: ${e.toString().replaceFirst('Exception: ', '')}')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse(String courseId) async {
    try {
      await _apiService.deleteCourse(courseId);
      await _fetchCourses();
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
      await _fetchCourses();
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              Navigator.pop(context);
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
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
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
        context.go('/drop-course');
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
    debugPrint('Building AllCoursesScreen. Filtered courses count: ${_filteredCourses.length}');
    return Scaffold(
      backgroundColor: AppColors.colorGrayBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                              'Add Courses',
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
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for courses...',
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
                    onChanged: (value) => _filterCourses(value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _errorMessage != null
                              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                              : _filteredCourses.isEmpty
                                  ? const Center(child: Text('No courses found.'))
                                  : Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        itemCount: _filteredCourses.length,
                                        itemBuilder: (context, index) {
                                          final course = _filteredCourses[index];
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
                                                                _selectedCourse = course;
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
                                                                          _selectedCourse = null;
                                                                        });
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: const Text('Cancel'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        _deleteCourse(course['id'].toString());
                                                                        setState(() {
                                                                          _selectedCourse = null;
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
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      OutlinedButton(
                                                        onPressed: () => _addCourse(course['id']),
                                                        style: OutlinedButton.styleFrom(
                                                          side: const BorderSide(color: AppColors.colorPrimary),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                        child: const Text('Add now'),
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
                    ),
                  ],
                ),
              ),
            ),
            FooterComponent(
              currentScreen: Screen.addCourse,
              onItemSelected: _handleScreenChange,
            ),
          ],
        ),
      ),
    );
  }
} 