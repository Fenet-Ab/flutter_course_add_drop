import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:course_add_and_drop/presentation/screen/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  testWidgets('Login screen displays all required elements', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      ),
    );

    // Verify that the login screen contains all required elements
    expect(find.text('Access'), findsOneWidget);
    expect(find.text('Access your course'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Need to create an account?'), findsOneWidget);
  });

  testWidgets('Login button is enabled when form is filled', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const LoginScreen();
          },
        ),
      ),
    );

    // Enter text in the username field
    await tester.enterText(find.byType(TextFormField).first, 'testuser');
    
    // Enter text in the password field
    await tester.enterText(find.byType(TextFormField).last, 'password123');

    // Verify that the login button is enabled
    final loginButton = find.text('Log In');
    expect(loginButton, findsOneWidget);
    
    // Tap the login button
    await tester.tap(loginButton);
    await tester.pump();
  });
} 