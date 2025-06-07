import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../components/course_card_component.dart';
import '../../components/text_field.dart' as text_field;

class AllCoursesScreen extends StatefulWidget {
  const AllCoursesScreen({super.key});

  @override
  State<AllCoursesScreen> createState() => _AllCoursesScreenState();
}

class _AllCoursesScreenState extends State<AllCoursesScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  String? _errorMessage;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCourses = [];
  Map<String, dynamic>? _selectedCourse;
  bool _showUpdateDialog = false;
  bool _showDeleteDialog = false;
  Map<String, dynamic>? _courseToDelete;

  // Controllers for the update dialog
  final TextEditingController _editTitleController = TextEditingController();
  final TextEditingController _editCodeController = TextEditingController();
  final TextEditingController _editDescriptionController = TextEditingController();
  final TextEditingController _editCreditHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _searchController.addListener(_filterCourses);
  }

  void _filterCourses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCourses = _courses.where((course) {
        final courseTitle = course['title']?.toLowerCase() ?? '';
        final courseCode = course['code']?.toLowerCase() ?? '';
        return courseTitle.contains(query) || courseCode.contains(query);
      }).toList();
    });
  }

  Future<void> _loadCourses() async {
    try {
      debugPrint('Attempting to fetch courses...');
      final courses = await _apiService.getCourses();
      debugPrint('Fetched ${courses.length} courses.');
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _filteredCourses = courses;
        _isLoading = false;
        debugPrint('Courses and filtered courses updated. Count: ${_filteredCourses.length}');
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error loading courses: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
      await _loadCourses();
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
      await _loadCourses();
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
    debugPrint('Building AllCoursesScreen. Filtered courses count: ${_filteredCourses.length}');
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
                      'All Courses',
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
              onChanged: (value) => _filterCourses(),
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
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
                    actionButtonText: 'Add now',
                    onAdd: () => _addCourse(course['id']),
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
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
              break;
            case 2:
              context.go('/drop-course');
              break;
            case 3:
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