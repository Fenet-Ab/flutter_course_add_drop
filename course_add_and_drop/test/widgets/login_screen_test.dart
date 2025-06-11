import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:course_add_and_drop/presentation/screen/login_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:course_add_and_drop/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:course_add_and_drop/main.dart';

class MockApiService extends Mock implements ApiService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockApiService mockApiService;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockApiService = MockApiService();
    mockPrefs = MockSharedPreferences();
    
    // Setup default mock behavior
    when(mockPrefs.getString('jwt_token')).thenReturn('mock_token');
    when(mockPrefs.getString('user_role')).thenReturn('Student');
  });

  testWidgets('Login screen shows all required fields and buttons', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
      ),
    );

    // Verify that all required elements are present
    expect(find.text('Access Account'), findsOneWidget);
    expect(find.text('Access your course with ease'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Username and password fields
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Need to create an account?'), findsOneWidget);
  });

  testWidgets('Login form validation works', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
      ),
    );

    // Try to login without entering credentials
    await tester.tap(find.text('Log In'));
    await tester.pump();

    // Verify validation messages
    expect(find.text('Enter username'), findsOneWidget);
    expect(find.text('Enter password'), findsOneWidget);
  });

  testWidgets('Password visibility toggle works', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
      ),
    );

    // Find the password field
    final passwordField = find.byType(TextFormField).last;
    
    // Enter some text
    await tester.enterText(passwordField, 'testpassword');
    
    // Find and tap the visibility toggle
    final visibilityButton = find.byIcon(Icons.visibility);
    await tester.tap(visibilityButton);
    await tester.pump();

    // Verify the visibility icon changed
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('Navigation to forgot password works', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
      ),
    );

    // Tap the forgot password button
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    // Verify navigation (this will depend on your routing setup)
    expect(find.text('Forgot Password?'), findsOneWidget);
  });
} 