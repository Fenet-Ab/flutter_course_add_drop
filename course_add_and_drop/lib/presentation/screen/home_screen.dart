import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:course_add_and_drop/theme/app_colors.dart'; // Assuming AppColors for consistency
import 'package:course_add_and_drop/components/button_component.dart'; // Assuming ButtonComponent exists

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorGrayBackground, // Light purple background
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.colorPrimary, width: 2.0), // Blue border
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder for the icon. Assuming it's in assets/
                  Image.asset(
                    'assets/logo.png', // This should be the correct path to your logo
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '''Welcome to the Course
          Add and Drop Manager App''',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 19, 91, 208), // Dark purple text
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '''Effortlessly manage your courses and stay
                    ahead in your academic journey!''',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.colorTextLight, // Gray text
                    ),
                  ),
                  const SizedBox(height: 50),
                  ButtonComponent(
                    value: 'Get Started',
                    onClick: () {
                      debugPrint('Navigating to /login from home screen');
                      context.go('/login');
                    },
                    isEnabled: true, // Always enabled
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 