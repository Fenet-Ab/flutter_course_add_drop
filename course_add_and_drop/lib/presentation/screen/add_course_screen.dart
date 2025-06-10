import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:course_add_and_drop/theme/app_colors.dart';
import 'package:course_add_and_drop/components/text.dart' as text;
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

class AdminCourseManagementScreen extends StatefulWidget {
  const AdminCourseManagementScreen({super.key});

  @override
  State<AdminCourseManagementScreen> createState() => _AdminCourseManagementScreenState();
}

class _AdminCourseManagementScreenState extends State<AdminCourseManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _allCourses = [];
  List<Map<String, dynamic>> _filteredCourses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedCourse;
  Map<String, dynamic>? _courseToDelete;
  bool _showUpdateDialog = false;
  bool _showDeleteDialog = false;
  bool _showAddDialog = false;
  Map<String, dynamic>? _courseToAdd;

  // Controllers for the update dialog
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editCodeController = TextEditingController();
  final TextEditingController _editDescriptionController = TextEditingController();
  final TextEditingController _editCreditHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('AdminCourseManagementScreen initState called');
    _fetchAllCourses();
  }

  Future<void> _fetchAllCourses() async {
    try {
      debugPrint('Starting to fetch all courses...');
      final courses = await _apiService.getCourses();
      debugPrint('Raw courses data: $courses');

      setState(() {
        _allCourses = List<Map<String, dynamic>>.from(courses);
        _filteredCourses = _allCourses;
        _isLoading = false;
      });
      debugPrint('Number of courses received: ${_allCourses.length}');
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
      await _fetchAllCourses();
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
      await _fetchAllCourses();
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
      backgroundColor: AppColors.colorGrayBackground,
      body: SafeArea(
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
                          onPressed: () => context.go('/dashboard/admin'),
                        ),
                        Expanded(
                          child: const Text(
                            'Add Course',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                      onTap: () {
                        debugPrint('Navigating to /edit-account');
                        context.push('/edit-account');
                      },
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('assets/profile.png'),
                      ),
                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: _filterCourses,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCourses.isEmpty
                        ? Center(
                            child: text.NormalTextComponent(
                              text: _searchQuery.isEmpty
                                  ? 'No courses available'
                                  : 'No courses found matching "$_searchQuery"',
                              color: AppColors.colorPrimary,
                            ),
                          )
                        : ListView.builder(
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                _courseToAdd = course;
                                                _showAddDialog = true;
                                              });
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Add Course'),
                                                  content: Text('Are you sure you want to add ${course['title']}?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _showAddDialog = false;
                                                          _courseToAdd = null;
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        // TODO: Implement add course logic
                                                        setState(() {
                                                          _showAddDialog = false;
                                                          _courseToAdd = null;
                                                        });
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Course added successfully')),
                                                        );
                                                      },
                                                      child: const Text('Add'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
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
            ],
          ),
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
