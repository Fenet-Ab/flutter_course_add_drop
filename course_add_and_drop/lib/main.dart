import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import './presentation/screen/approval_status_screen.dart';
import './presentation/screen/edit_account_screen.dart';

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
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  final ValueNotifier<bool> _authNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();

    _router = GoRouter(
      refreshListenable: _authNotifier,
      initialLocation: '/loading',
      routes: [
        GoRoute(
          path: '/loading',
          builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
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
        GoRoute(
          path: '/edit-account',
          builder: (context, state) => const EditAccountScreen(),
        ),
      ],
      redirect: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        final role = prefs.getString('user_role');
        final loggedIn = token != null && role != null;

        final targetPath = state.uri.toString();
        final isAuthPage = [
          '/login',
          '/signup',
          '/forgot-password',
          '/terms',
        ].contains(targetPath);

        debugPrint('GoRouter Redirect: Current Path: $targetPath');
        debugPrint('GoRouter Redirect: Logged In: $loggedIn, Role: $role');

        // If not logged in and trying to access a protected page
        if (!loggedIn && !isAuthPage && targetPath != '/loading') {
          debugPrint('GoRouter Redirect: Not logged in, redirecting to /login');
          return '/login';
        }

        // If logged in and trying to access an auth page (login/signup etc.)
        if (loggedIn && isAuthPage) {
          String homeRoute = (role == 'Registrar') ? '/dashboard/admin' : '/dashboard/user';
          debugPrint('GoRouter Redirect: Logged in, redirecting from auth page to $homeRoute');
          return homeRoute;
        }

        // If trying to access /loading after auth status is known
        if (loggedIn && targetPath == '/loading') {
          String homeRoute = (role == 'Registrar') ? '/dashboard/admin' : '/dashboard/user';
          debugPrint('GoRouter Redirect: Logged in, redirecting from /loading to $homeRoute');
          return homeRoute;
        }
        if (!loggedIn && targetPath == '/loading') {
          debugPrint('GoRouter Redirect: Not logged in, redirecting from /loading to /login');
          return '/login';
        }

        // For dashboard routes, verify the role matches
        if (loggedIn && targetPath.startsWith('/dashboard/')) {
          final isAdminRoute = targetPath == '/dashboard/admin';
          final isAdminRole = role == 'Registrar';
          
          if ((isAdminRoute && !isAdminRole) || (!isAdminRoute && isAdminRole)) {
            String correctRoute = isAdminRole ? '/dashboard/admin' : '/dashboard/user';
            debugPrint('GoRouter Redirect: Role mismatch, redirecting to correct route: $correctRoute');
            return correctRoute;
          }
        }

        // No redirect needed, proceed to the target path
        debugPrint('GoRouter Redirect: No redirect needed, proceeding to $targetPath');
        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Route not found: ${state.uri}')),
      ),
    );
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final role = prefs.getString('user_role');
    
    debugPrint('Checking auth status - Token: ${token != null}, Role: $role');
    
    if (token != null && role != null) {
      _authNotifier.value = true;
      debugPrint('Auth status: Logged in as $role');
    } else {
      _authNotifier.value = false;
      debugPrint('Auth status: Not logged in');
    }
  }

  @override
  void dispose() {
    _authNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3B82F6),
        scaffoldBackgroundColor: const Color(0xFFE0E7FF),
        useMaterial3: true,
      ),
    );
  }
}