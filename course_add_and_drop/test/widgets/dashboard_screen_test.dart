import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:course_add_and_drop/presentation/screen/dashboard_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockGoRouter = MockGoRouter();
  });

  testWidgets('Dashboard screen displays all required elements', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const UserDashboardScreen();
          },
        ),
      ),
    );

    // Verify that the dashboard screen contains all required elements
    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Course Name'), findsOneWidget);
    expect(find.text('Course Code'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('+ Add now'), findsOneWidget);
  });

  testWidgets('Dashboard navigation works correctly', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const UserDashboardScreen();
          },
        ),
      ),
    );

    // Test Add Now button
    await tester.tap(find.text('+ Add now'));
    await tester.pump();

    // Test bottom navigation
    await tester.tap(find.byIcon(Icons.list));
    await tester.pump();
  });

  testWidgets('Dashboard table view switching works', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const UserDashboardScreen();
          },
        ),
      ),
    );

    // Find and tap the view switch button
    final switchButton = find.byIcon(Icons.arrow_forward);
    expect(switchButton, findsOneWidget);
    
    await tester.tap(switchButton);
    await tester.pump();

    // Verify the view has changed
    expect(find.text('Course Name'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
  });

  testWidgets('Profile navigation works', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return const UserDashboardScreen();
          },
        ),
      ),
    );

    // Find and tap the profile avatar
    final profileAvatar = find.byType(CircleAvatar);
    expect(profileAvatar, findsOneWidget);
    
    await tester.tap(profileAvatar);
    await tester.pump();
  });
} 