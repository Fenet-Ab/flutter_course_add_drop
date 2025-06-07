import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import './presentation/screen/login_screen.dart';
import './presentation/screen/signUp_screen.dart';
import './presentation/screen/terms_and_conditions.dart';
import './presentation/screen/forget_password_screen.dart';
import './presentation/screen/dashboard_screen.dart';
import './presentation/screen/admin_dashboard_screen.dart';
import './presentation/screen/all_courses_screen.dart';
import './presentation/screen/add_course_screen.dart';
import './presentation/screen/select_academic_year_screen.dart';
import './presentation/screen/drop_course_screen.dart';
import './presentation/screen/admin_dashboard_screen.dart';
import './presentation/screen/approval_status_screen.dart';

// void main() {
//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final GoRouter router = GoRouter(
//       initialLocation: '/signup',
//       routes: [
//         GoRoute(
//           path: '/signup',
//           builder: (context, state) => const SignUpScreen(),
//         ),
//         GoRoute(
//           path: '/login',
//           builder: (context, state) => const LoginScreen(),
//         ),
//         GoRoute(
//           path: '/terms',
//           builder: (context, state) => const TermsAndConditionsScreen(),
//         ),
//         GoRoute(
//           path: '/forgot-password',
//           builder: (context, state) => const ForgetPasswordScreen(),
//         ),
//         GoRoute(
//           path: '/dashboard',
//           builder: (context, state) => const UserDashboardScreen(),
//         ),
//       ],
//       errorBuilder: (context, state) => Scaffold(
//         body: Center(child: Text('Route not found: ${state.uri}')),
//       ),
//     );

//     return MaterialApp.router(
//       routerConfig: router,
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF3B82F6),
//         scaffoldBackgroundColor: const Color(0xFFE0E7FF),
//         useMaterial3: true,
//       ),
//     );
//   }
// }


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/signup',
      routes: [
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const TermsAndConditionsScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgetPasswordScreen(),
        ),
        GoRoute(
          path: '/dashboard/user',
          builder: (context, state) => const UserDashboardScreen(),
        ),
        GoRoute(
          path: '/dashboard/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/courses/all',
          builder: (context, state) => const AllCoursesScreen(),
        ),
        GoRoute(
          path: '/courses/add',
          builder: (context, state) => const AdminCourseManagementScreen(),
        ),
        GoRoute(
          path: '/select-academic-year',
          builder: (context, state) => const SelectAcademicYearScreen(),
        ),
        GoRoute(
          path: '/drop-course',
          builder: (context, state) => const DropCourseScreen(),
        ),
        GoRoute(
          path: '/approval-status',
          builder: (context, state) => const ApprovalStatusScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Route not found: ${state.uri}')),
      ),
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFFE0E7FF),
        useMaterial3: true,
      ),
    );
  }
}