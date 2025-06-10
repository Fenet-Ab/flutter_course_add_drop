import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:course_add_and_drop/main.dart' as app;
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    setUp(() async {
      // Clear any existing preferences before each test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('Complete user journey test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Home Screen
      expect(find.text('Welcome to the Course'), findsOneWidget);
      expect(find.text('Add and Drop Manager App'), findsOneWidget);

      // 2. Navigate to Login
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // 3. Login Screen
      expect(find.text('Access'), findsOneWidget);
      expect(find.text('Access your course'), findsOneWidget);

      // 4. Navigate to Sign Up
      await tester.tap(find.text('Need to create an account?'));
      await tester.pumpAndSettle();

      // 5. Sign Up Screen
      expect(find.text('Create Account'), findsOneWidget);
      
      // Fill sign up form
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'johndoe');
      await tester.enterText(find.byType(TextFormField).at(3), '12345');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');
      
      // Check terms and conditions
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Submit sign up
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // 6. Dashboard Screen
      expect(find.text('Welcome,'), findsOneWidget);
      
      // Test Add Course flow
      await tester.tap(find.text('+ Add now'));
      await tester.pumpAndSettle();

      // 7. Academic Year Selection Screen
      expect(find.text('Select Academic Year and Semester'), findsOneWidget);
      
      // Select academic year
      await tester.tap(find.text('Select Year'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023/2024'));
      await tester.pumpAndSettle();

      // Select semester
      await tester.tap(find.text('Select semester'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();

      // Select Add/Drop
      await tester.tap(find.text('Add/Drop'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // 8. Test bottom navigation
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // 9. Test profile navigation
      await tester.tap(find.byType(CircleAvatar));
      await tester.pumpAndSettle();

      // 10. Test logout
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
    });

    testWidgets('Error handling test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Try to login with invalid credentials
      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.enterText(find.byType(TextFormField).last, 'invalid');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Error:'), findsOneWidget);
    });
  });
} 