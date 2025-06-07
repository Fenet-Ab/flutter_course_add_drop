import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_services.dart';
import 'package:flutter/foundation.dart';
import 'package:course_add_and_drop/components/add_drop_component.dart' as add_drop_components;
import '../../components/button_component.dart' as button;
import '../../components/text_field.dart' as text_field;
import '../../core/constants/app_colors.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _authService.forgotPassword(_emailController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset instructions sent')),
      );
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                onPressed: () => context.go('/login'),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const add_drop_components.HeadingTextComponent(
                         value: 'Forgot Password?',
                      ),
                      const SizedBox(height: 10),
                      const add_drop_components.NormalTextComponent(
                        value: 'Enter your registered email to receive reset instructions.',
                      ),
                      const SizedBox(height: 24),
                      text_field.TextFieldComponent(
                        controller: _emailController,
                        label: 'Enter your email',
                        assetPath: 'assets/email.png', // Assuming you have an email icon asset
                        validator: (value) =>
                            value!.isEmpty || !value.contains('@') ? 'Enter valid email' : null,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 16),
                      button.ButtonComponent(
                        value: 'Reset Password',
                        onClick: _resetPassword,
                        isEnabled: !_isLoading,
                      ),
                      const SizedBox(height: 15),
                     
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
}