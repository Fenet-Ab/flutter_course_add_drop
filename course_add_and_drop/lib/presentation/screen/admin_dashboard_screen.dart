import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../components/button_component.dart' as button;
import '../components/text_field.dart' as text_field;
import '../../components/add_drop_component.dart' as add_drop_components;
import 'package:flutter/foundation.dart';
import 'package:course_add_and_drop/main.dart';
import '../../components/footer_component.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _creditHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('Asset paths being used:');
    debugPrint('title.png: assets/title.png');
    debugPrint('code.png: assets/code.png');
    debugPrint('description.png: assets/description.png');
    debugPrint('credit.png: assets/credit.png');
    
    // Load data using Riverpod
    Future.microtask(() {
      ref.read(adminDashboardProvider.notifier).loadData();
      ref.read(adminDashboardProvider.notifier).loadUserRole();
      ref.read(adminDashboardProvider.notifier).loadUserName();
    });
  }

  Future<void> _createCourse() async {
    if (_titleController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _creditHoursController.text.isEmpty) {
      return;
    }

    await ref.read(adminDashboardProvider.notifier).createCourse(
      title: _titleController.text,
      code: _codeController.text,
      description: _descriptionController.text,
      creditHours: _creditHoursController.text,
    );

    // Clear controllers after successful creation
    _titleController.clear();
    _codeController.clear();
    _descriptionController.clear();
    _creditHoursController.clear();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('Clearing local SharedPreferences on logout for admin dashboard.');
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    await prefs.remove('user_username');
    await prefs.remove('user_full_name');
    await prefs.remove('user_email');
    await prefs.remove('user_profile_photo');

    authNotifier.value = false;
    debugPrint('authNotifier set to false via admin_dashboard_screen.dart after local clear.');

    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Navigating to /login via addPostFrameCallback from admin dashboard.');
      context.go('/login');
    });

    Future.microtask(() async {
      try {
        await ref.read(apiServiceProvider).logout();
        debugPrint('API Service backend logout completed from admin dashboard.');
      } catch (e) {
        debugPrint('Error during API Service backend logout from admin dashboard: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backend logout failed: ${e.toString().replaceFirst('Exception: ', '')}')),
          );
        }
      }
    });
  }

  void _handleScreenChange(Screen screen) {
    debugPrint('Handling screen change in admin dashboard: $screen');
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
        debugPrint('Navigating to admin dashboard');
        if (mounted) {
          context.go('/dashboard/admin');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminDashboardProvider);

    if (state.isLoading) {
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
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          debugPrint('Navigating to /edit-account from admin dashboard.');
                          context.push('/edit-account');
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/profile.png'),
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
                            state.userName ?? 'Admin',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  add_drop_components.TextFieldComponent(
                    controller: _titleController,
                    label: 'Title',
                    assetPath: 'assets/title.png',
                    validator: (value) => value!.isEmpty ? 'Enter title' : null,
                    onValueChange: (value) {},
                  ),
                  const SizedBox(height: 16),
                  add_drop_components.TextFieldComponent(
                    controller: _codeController,
                    label: 'Code',
                    assetPath: 'assets/code.png',
                    validator: (value) => value!.isEmpty ? 'Enter code' : null,
                    onValueChange: (value) {},
                  ),
                  const SizedBox(height: 16),
                  add_drop_components.TextFieldComponent(
                    controller: _descriptionController,
                    label: 'Description',
                    assetPath: 'assets/description.png',
                    validator: (value) => value!.isEmpty ? 'Enter description' : null,
                    onValueChange: (value) {},
                  ),
                  const SizedBox(height: 16),
                  add_drop_components.TextFieldComponent(
                    controller: _creditHoursController,
                    label: 'Credit Hours',
                    assetPath: 'assets/credit.png',
                    validator: (value) => value!.isEmpty ? 'Enter credit hours' : null,
                    onValueChange: (value) {},
                  ),
                  const SizedBox(height: 30),
                  add_drop_components.ButtonComponent(
                    value: 'Save',
                    onClick: _createCourse,
                    enabled: true,
                  ),
                  if (state.successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(state.successMessage, style: const TextStyle(color: Colors.green)),
                    ),
                  if (state.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(state.errorMessage, style: const TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          FooterComponent(
            currentScreen: Screen.dashboard,
            onItemSelected: _handleScreenChange,
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