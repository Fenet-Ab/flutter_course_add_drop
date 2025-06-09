import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:course_add_and_drop/core/constants/app_colors.dart';
import 'package:course_add_and_drop/presentation/providers/signup_provider.dart';
import 'package:course_add_and_drop/presentation/screen/terms_and_conditions.dart';
import 'package:course_add_and_drop/components/add_drop_component.dart' as add_drop_components;
import '../../services/api_service.dart';
import '../../data/model/user.dart';
import '../../components/button_component.dart' as button;
import '../../components/clickable_login.dart' as login;
import '../../components/text_field.dart' as text_field;
import 'package:flutter/foundation.dart';



class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  File? _profilePhoto;
  bool _isLoading = false;
  String? _errorMessage;
  String? _idStatus;
  bool _isIdAvailable = false;
  bool _isPasswordVisible = false;
  bool _isChecked = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profilePhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _checkIdAvailability() async {
    final id = int.tryParse(_idController.text);
    if (id == null) {
      setState(() {
        _idStatus = 'Invalid ID';
        _isIdAvailable = false;
      });
      return;
    }

    try {
      final result = await _apiService.checkIdAvailability(id);
      setState(() {
        _isIdAvailable = result['available'] == true;
        _idStatus = _isIdAvailable
            ? 'ID available (Role: ${result['role']})'
            : result['error'] ?? 'ID not available';
      });
    } catch (e) {
      setState(() {
        _idStatus = e.toString().replaceFirst('Exception: ', '');
        _isIdAvailable = false;
      });
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete ID validation and fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Creating user with username: ${_usernameController.text}');
      final user = User(
        id: int.parse(_idController.text),
        username: _usernameController.text,
        password: _passwordController.text,
        email: _emailController.text,
        fullName: _fullNameController.text,
        role: 'Student', // Default, adjusted by backend
      );

      final response = await _apiService.signUp(user, _profilePhoto);
      debugPrint('Signup response: $response');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      debugPrint('Navigating to /login');
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const add_drop_components.HeadingTextComponent(value: 'Create Account'),
                const SizedBox(height: 10),
                const add_drop_components.NormalTextComponent(value: 'Create your account to get started'),
                const SizedBox(height: 20),
                
                text_field.TextFieldComponent(
                  controller: _fullNameController,
                  label: 'Enter your full name',
                  assetPath: 'assets/profile.png',
                  validator: (value) => value!.isEmpty ? 'Enter full name' : null,
                  onChanged: (value) {},
                ),
                text_field.TextFieldComponent(
                  controller: _emailController,
                  label: 'Enter your email',
                  assetPath: 'assets/email.png',
                  validator: (value) => value!.isEmpty ? 'Enter email' : null,
                  onChanged: (value) {},
                ),
                text_field.TextFieldComponent(
                  controller: _usernameController,
                  label: 'Enter your username',
                  assetPath: 'assets/profile.png',
                  validator: (value) => value!.isEmpty ? 'Enter username' : null,
                  onChanged: (value) {},
                ),
                text_field.TextFieldComponent(
                  controller: _idController,
                  label: 'Your ID',
                  assetPath: 'assets/id_image.png',
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter ID' : null,
                  onChanged: (value) {},
                ),
                if (_idStatus != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      _idStatus!,
                      style: TextStyle(
                        color: _isIdAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                add_drop_components.PasswordTextFieldComponent(
                  controller: _passwordController,
                  label: 'Enter your password',
                  assetPath: 'assets/password.png',
                  isVisible: _isPasswordVisible,
                  onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  onValueChange: (value) {},
                  validator: (value) => value!.isEmpty ? 'Enter password' : null,
                ),
                add_drop_components.TextFieldPhotoComponent(
                  labelValue: 'Upload your picture',
                  assetName: 'assets/upload.png',
                  contentDescription: 'Upload Picture',
                  onTap: _pickImage,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          debugPrint('Navigating to /terms');
                          context.push('/terms');
                        },
                        child: const Text('Agree with terms and conditions.'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
                button.ButtonComponent(
                  value: _isLoading ? 'Registering...' : 'Sign Up',
                  onClick: _signUp,
                  isEnabled:!_isLoading && _isChecked && _fullNameController.text.isNotEmpty && _idController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty,
                ),
                const SizedBox(height: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 8, 8, 8), // Gray from image
                      ),
                    ),
                    const SizedBox(height: 5), // Add a small space between the two lines
                    GestureDetector(
                      onTap: () {
                        debugPrint('Navigating to /login');
                        context.go('/login');
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3B82F6), // Purple from image
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}


