import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_services.dart';
import 'package:course_add_and_drop/components/add_drop_component.dart';
import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../components/button_component.dart' as button;
import '../../components/clickable_login.dart' as login;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Attempting login with username: ${_usernameController.text}');
      final response = await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );
      
      if (!mounted) return;
      
      final role = response['role'] as String?;
      final username = response['username'] as String?;
      debugPrint('Login successful, role: $role, username: $username');

      // Get SharedPreferences instance and verify data
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final savedRole = prefs.getString('user_role');
      
      debugPrint('Stored token: $token');
      debugPrint('Stored role: $savedRole');

      if (token == null || savedRole == null) {
        throw Exception('Failed to save login credentials');
      }

      // Wait for token to be saved and persisted
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate based on role
      if (savedRole == 'Registrar') {
        debugPrint('Navigating to /dashboard/admin');
        if (!mounted) return;
        context.go('/dashboard/admin');
      } else if (savedRole == 'Student') {
        debugPrint('Navigating to /dashboard/user');
        if (!mounted) return;
        context.go('/dashboard/user');
      } else {
        throw Exception('Invalid user role: $savedRole');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  debugPrint('Navigating to /signup');
                  context.go('/signup');
                },
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const HeadingTextComponent(value: 'Access'),
                      const SizedBox(height: 10),
                      const NormalTextComponent(value: 'Access your course'),
                      const SizedBox(height: 25),
                      TextFieldComponent(
                        controller: _usernameController,
                        label: 'Username',
                        assetPath: 'assets/profile.png',
                        validator: (value) => value!.isEmpty ? 'Enter username' : null,
                      ),
                      PasswordTextFieldComponent(
                        controller: _passwordController,
                        label: 'Password',
                        assetPath: 'assets/password.png',
                        isVisible: _isPasswordVisible,
                        onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        validator: (value) => value!.isEmpty ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 15),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            debugPrint('Navigating to /forgot-password');
                            context.go('/forgot-password');
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Color(0xFF3B82F6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      button.ButtonComponent(
                        value: _isLoading ? 'Logging In...' : 'Log In',
                        onClick: _login,
                        isEnabled: !_isLoading,
                      ),
                      const SizedBox(height: 15),
                      const NormalTextComponent(value: 'Need to create an account?'),
                      login.ClickableLoginTextComponent(
                        onTextSelected: () {
                          debugPrint('Navigating to /signup');
                          context.go('/signup');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
