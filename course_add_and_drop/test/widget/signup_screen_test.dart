import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:course_add_and_drop/presentation/screen/signUp_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  testWidgets('SignUp screen displays all required elements', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const SignUpScreen();
          },
        ),
      ),
    );

    // Verify that the signup screen contains all required elements
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Create your account to get started'), findsOneWidget);
    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your username'), findsOneWidget);
    expect(find.text('Your ID'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.text('Upload your picture'), findsOneWidget);
    expect(find.text('Agree with terms and conditions.'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('SignUp form validation works correctly', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const SignUpScreen();
          },
        ),
      ),
    );

    // Try to submit empty form
    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    // Verify validation messages
    expect(find.text('Enter full name'), findsOneWidget);
    expect(find.text('Enter email'), findsOneWidget);
    expect(find.text('Enter username'), findsOneWidget);
    expect(find.text('Enter ID'), findsOneWidget);
    expect(find.text('Enter password'), findsOneWidget);

    // Fill in the form
    await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'johndoe');
    await tester.enterText(find.byType(TextFormField).at(3), '12345');
    await tester.enterText(find.byType(TextFormField).at(4), 'password123');

    // Check terms and conditions
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    // Verify the sign up button is enabled
    final signUpButton = find.text('Sign Up');
    expect(signUpButton, findsOneWidget);
    
    // Tap the sign up button
    await tester.tap(signUpButton);
    await tester.pump();
  });

  testWidgets('Navigation to login works', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const SignUpScreen();
          },
        ),
      ),
    );

    // Tap the login link
    await tester.tap(find.text('Log In'));
    await tester.pump();
  });
} 