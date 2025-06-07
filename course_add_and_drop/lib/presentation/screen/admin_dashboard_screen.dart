import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../components/button_component.dart' as button;
import '../components/text_field.dart' as text_field;
import '../../components/add_drop_component.dart' as add_drop_components;
import 'package:flutter/foundation.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _creditHoursController = TextEditingController();
  final ApiService _apiService = ApiService();
  String? _token;
  String _successMessage = '';
  String _errorMessage = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _adds = [];
  String _adminName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final token = prefs.getString('jwt_token');
      if (token != null) {
        final user = await _apiService.getUserProfile();
        if (!mounted) return;
        setState(() {
          _adminName = user.fullName;
        });
      }
      final adds = await _apiService.getAdds();
      if (!mounted) return;
      setState(() {
        _token = token;
        _adds = adds;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _createCourse() async {
    if (_titleController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _creditHoursController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
        _successMessage = '';
      });
      return;
    }

    try {
      final response = await _apiService.createCourse(
        title: _titleController.text,
        code: _codeController.text,
        description: _descriptionController.text,
        creditHours: _creditHoursController.text,
      );
      if (!mounted) return;
      setState(() {
        _successMessage = response['message'] ?? 'Course created successfully';
        _errorMessage = '';
        _titleController.clear();
        _codeController.clear();
        _descriptionController.clear();
        _creditHoursController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _successMessage = '';
      });
    }
  }

  Future<void> _approveAdd(int addId, String status) async {
    try {
      await _apiService.approveAdd(addId, status);
      if (!mounted) return;
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add $status')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    if (!mounted) return;
    debugPrint('Navigating to /login');
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _token == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      debugPrint('Navigating to /approval-status');
                      context.go('/approval-status');
                    },
                    padding: const EdgeInsets.only(top: 15, right: 10),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _adminName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  add_drop_components.TextFieldComponent(
                    controller: _titleController,
                    label: 'Title',
                    assetPath: 'assets/profile.png',
                    validator: (value) => value!.isEmpty ? 'Enter title' : null,
                    onValueChange: (value) {},
                  ),
                  add_drop_components.TextFieldComponent(
                    controller: _codeController,
                    label: 'Code',
                    assetPath: 'assets/profile.png',
                    validator: (value) => value!.isEmpty ? 'Enter code' : null,
                    onValueChange: (value) {},
                  ),
                  add_drop_components.TextFieldComponent(
                    controller: _descriptionController,
                    label: 'Description',
                    assetPath: 'assets/profile.png',
                    validator: (value) => value!.isEmpty ? 'Enter description' : null,
                    onValueChange: (value) {},
                  ),
                  add_drop_components.TextFieldComponent(
                    controller: _creditHoursController,
                    label: 'Credit Hours',
                    assetPath: 'assets/profile.png',
                    validator: (value) => value!.isEmpty ? 'Enter credit hours' : null,
                    onValueChange: (value) {},
                  ),
                  const SizedBox(height: 30),
                  add_drop_components.ButtonComponent(
                    value: 'Save',
                    onClick: _createCourse,
                    enabled: true,
                  ),
                  if (_successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_successMessage, style: const TextStyle(color: Colors.green)),
                    ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 20),
                 
                  const SizedBox(height: 20),
                  
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
                context.go('/dashboard/admin');
              } else {
                context.go('/courses/all');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _creditHoursController.dispose();
    super.dispose();
  }
}