import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../components/course_card_component.dart';
import 'package:flutter/foundation.dart';
import 'package:course_add_and_drop/theme/app_colors.dart';
import 'package:course_add_and_drop/components/text.dart' as text;

class DropCourseScreen extends StatefulWidget {
  const DropCourseScreen({super.key});

  @override
  State<DropCourseScreen> createState() => _DropCourseScreenState();
}

class _DropCourseScreenState extends State<DropCourseScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _filteredCourses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedCourse;
  Map<String, dynamic>? _courseToDelete;
  bool _showUpdateDialog = false;
  bool _showDeleteDialog = false;

  // Add controllers for edit dialog
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editCodeController = TextEditingController();
  final TextEditingController _editDescriptionController = TextEditingController();
  final TextEditingController _editCreditHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('DropCourseScreen initState called');
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      debugPrint('Starting to fetch courses...');
      final courses = await _apiService.getCourses();
      debugPrint('Raw courses data: $courses');
      
      setState(() {
        _courses = List<Map<String, dynamic>>.from(courses);
        _filteredCourses = _courses;
        _isLoading = false;
      });
      debugPrint('Number of courses received: ${_courses.length}');
    } catch (e) {
      debugPrint('Error fetching courses: $e');
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

  void _filterCourses(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCourses = _courses;
      } else {
        _filteredCourses = _courses.where((course) {
          final title = course['title']?.toString().toLowerCase() ?? '';
          final description = course['description']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return title.contains(searchLower) || description.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _dropCourse(String courseId) async {
    try {
      await _apiService.deleteCourse(courseId);
      await _fetchCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course dropped successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error dropping course: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      body: Column(
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
                      onPressed: () => context.go('/dashboard/user'),
                    ),
                    const Text(
                      'Drop Course',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/profile.png'),
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
              decoration: const InputDecoration(
                labelText: 'Search courses...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterCourses,
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_filteredCourses.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No courses available.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: _filteredCourses.length,
                itemBuilder: (context, index) {
                  final course = _filteredCourses[index];
                  return CourseCardComponent(
                    title: course['title'] ?? 'N/A',
                    description: course['description'] ?? 'N/A',
                    creditHours: course['credit_hours']?.toString() ?? 'N/A',
                    actionButtonText: 'Drop now',
                    onAdd: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Drop Course'),
                          content: Text('Are you sure you want to drop ${course['title']}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _dropCourse(course['id'].toString());
                                Navigator.pop(context);
                              },
                              child: const Text('Drop', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onEdit: () {
                      setState(() {
                        _selectedCourse = course;
                        _showUpdateDialog = true;
                      });
                      _showUpdateCourseDialog(course);
                    },
                    onDelete: () {
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
                                _dropCourse(course['id'].toString());
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
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_circle),
            label: 'Drop Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Courses',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard/user');
              break;
            case 1:
              context.go('/add-course');
              break;
            case 2:
              break;
            case 3:
              context.go('/all-courses');
              break;
          }
        },
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
