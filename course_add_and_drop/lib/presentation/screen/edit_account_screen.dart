import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:course_add_and_drop/components/add_drop_component.dart' as add_drop_components;
import 'package:course_add_and_drop/components/button_component.dart' as button;
import 'package:course_add_and_drop/components/text_field.dart' as text_field;
import 'package:course_add_and_drop/services/api_service.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  
  String? _profilePhotoUrl; // For displaying existing network image
  XFile? _pickedProfileXFile; // For new image picked from gallery (XFile for web compatibility)
  final ImagePicker _picker = ImagePicker();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    debugPrint('Loading user profile...');
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = await _apiService.getUserProfile();
      debugPrint('User profile fetched: ${user.toJson()}');
      if (!mounted) return;
      setState(() {
        _fullNameController.text = user.fullName;
        _usernameController.text = user.username;
        _emailController.text = user.email;
        _profilePhotoUrl = user.profilePhoto;
        _isLoading = false;
        debugPrint('Profile controllers updated: Full Name: ${user.fullName}, Username: ${user.username}, Email: ${user.email}');
      });
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedProfileXFile = pickedFile;
          _profilePhotoUrl = null;
          debugPrint('Profile photo picked: ${pickedFile.name}');
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and correct errors.')),
      );
      return;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      debugPrint('Attempting to save account...');
      await _apiService.updateProfile(
        fullName: _fullNameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        profilePhotoXFile: _pickedProfileXFile,
        newPassword: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      if (!mounted) return;
      setState(() {
        _successMessage = 'Profile updated successfully';
        _isLoading = false;
        _passwordController.clear();
        _confirmPasswordController.clear();
        debugPrint('Profile updated successfully, clearing password fields.');
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')), // More visible confirmation
      );

      // Re-fetch profile after successful update to ensure latest data is displayed
      await _loadUserProfile();

    } catch (e) {
      debugPrint('Error saving account: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $_errorMessage')),
      );
      // If session expired, redirect to login
      if (e.toString().contains('Session expired')) {
        _logout();
      }
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _deleteAccount() async {
    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Account Deletion'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User cancels
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // User confirms
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false; // Default to false if dialog is dismissed

    if (!confirmDelete) {
      return; // User cancelled deletion
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      debugPrint('Attempting to delete account...');
      final response = await _apiService.deleteProfile();

      if (!mounted) return;
      setState(() {
        _successMessage = response['message'] ?? 'Account deleted successfully';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_successMessage!)),
      );

      debugPrint('Account deleted successfully, navigating to /login');
      // The deleteProfile method in ApiService already clears SharedPreferences and sets authNotifier.value = false
      context.go('/login'); // Navigate to login after successful deletion

    } catch (e) {
      debugPrint('Error deleting account: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $_errorMessage')),
      );
      // If deletion fails due to session expiry, ensure logout state
      if (e.toString().contains('Session expired')) {
        _logout(); // This will clear local state and redirect to login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with back button and profile
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: _pickedProfileXFile != null
                                        ? (kIsWeb
                                            ? (_pickedProfileXFile!.path.startsWith('blob:') // Check if it's a blob URL for web
                                                ? NetworkImage(_pickedProfileXFile!.path) as ImageProvider // Treat blob as network image
                                                : MemoryImage(Uint8List.fromList([]))) // Fallback for other XFile on web for now
                                            : FileImage(File(_pickedProfileXFile!.path)) as ImageProvider)
                                        : (_profilePhotoUrl != null
                                            ? NetworkImage(_profilePhotoUrl!)
                                            : const AssetImage('assets/profile.png') as ImageProvider),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: _logout,
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _deleteAccount,
                                  child: const Text(
                                    'Delete Account',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Title
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                        child: Text(
                          'Edit Your Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                      // Profile Photo Upload
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _pickedProfileXFile != null
                                    ? (kIsWeb
                                        ? (_pickedProfileXFile!.path.startsWith('blob:') // Check if it's a blob URL for web
                                            ? NetworkImage(_pickedProfileXFile!.path) as ImageProvider // Treat blob as network image
                                            : MemoryImage(Uint8List.fromList([]))) // Fallback for other XFile on web for now
                                        : FileImage(File(_pickedProfileXFile!.path)) as ImageProvider)
                                    : (_profilePhotoUrl != null
                                        ? NetworkImage(_profilePhotoUrl!)
                                        : const AssetImage('assets/profile.png') as ImageProvider),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _pickImage,
                              child: const Text(
                                'Change Profile Photo',
                                style: TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Form fields
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            text_field.TextFieldComponent(
                              controller: _fullNameController,
                              label: 'Full Name',
                              assetPath: 'assets/profile.png',
                              validator: (value) => value!.isEmpty ? 'Full Name is required' : null,
                            ),
                            text_field.TextFieldComponent(
                              controller: _usernameController,
                              label: 'Username',
                              assetPath: 'assets/profile.png',
                              validator: (value) => value!.isEmpty ? 'Username is required' : null,
                            ),
                            text_field.TextFieldComponent(
                              controller: _emailController,
                              label: 'Email',
                              assetPath: 'assets/email.png',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => value!.isEmpty ? 'Email is required' : null,
                            ),
                            add_drop_components.PasswordTextFieldComponent(
                              controller: _passwordController,
                              label: 'New Password',
                              assetPath: 'assets/password.png',
                              isVisible: _isPasswordVisible,
                              onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              validator: (value) {
                                if (value!.isNotEmpty && value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            add_drop_components.PasswordTextFieldComponent(
                              controller: _confirmPasswordController,
                              label: 'Confirm New Password',
                              assetPath: 'assets/password.png',
                              isVisible: _isConfirmPasswordVisible,
                              onVisibilityToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                              validator: (value) {
                                if (value!.isNotEmpty && value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            if (_successMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                            button.ButtonComponent(
                              value: _isLoading ? 'Saving...' : 'Save Changes',
                              onClick: _saveAccount,
                              isEnabled: !_isLoading,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
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
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
} 