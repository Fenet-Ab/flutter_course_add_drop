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
import './presentation/screen/home_screen.dart';

// Global ValueNotifier for authentication status
final ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);

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

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure _checkAuthStatus runs after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });

    _router = GoRouter(
      refreshListenable: authNotifier,
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
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
        final loggedIn = authNotifier.value; // From global notifier
        String? role; // Initialize role as nullable

        // Only fetch role from SharedPreferences if considered logged in by authNotifier
        if (loggedIn) {
          final prefs = await SharedPreferences.getInstance();
          role = prefs.getString('user_role');
        }

        final targetPath = state.uri.toString();
        final isAuthPage = [
          '/login',
          '/signup',
          '/forgot-password',
          '/terms',
          // '/home', // Removed /home from isAuthPage to allow logged-in users to access it
        ].contains(targetPath);

        debugPrint('GoRouter Redirect: Current Path: $targetPath');
        debugPrint('GoRouter Redirect: Logged In (from Notifier): $loggedIn, Role: $role');

        // === CRITICAL REDIRECT LOGIC REFINEMENT ===

        // Scenario 1: User is NOT logged in
        if (!loggedIn) {
          // If trying to access a protected page (anything not auth or loading), redirect to home
          if (!isAuthPage && targetPath != '/loading' && targetPath != '/home') { // Added targetPath != '/home'
            debugPrint('GoRouter Redirect: Not logged in and accessing protected page, redirecting to /home');
            return '/home';
          }
          // If trying to access /loading when not logged in, redirect to home
          if (targetPath == '/loading') {
            debugPrint('GoRouter Redirect: Not logged in and on /loading, redirecting to /home');
            return '/home';
          }
          // If not logged in but trying to access an auth page (including home), allow it.
          debugPrint('GoRouter Redirect: Not logged in, allowing access to auth page: $targetPath');
          return null; // Allow navigation to auth pages
        }

        // Scenario 2: User IS logged in (loggedIn is true at this point)

        // If logged in and trying to access an auth page (login/signup etc., but NOT /home now), redirect to home dashboard
        if (isAuthPage && targetPath != '/home') { // Added targetPath != '/home' here as well
          String homeRoute = (role == 'Registrar') ? '/dashboard/admin' : '/dashboard/user';
          debugPrint('GoRouter Redirect: Logged in and on auth page ($targetPath), redirecting to home dashboard: $homeRoute');
          return homeRoute; // Redirect to user's dashboard
        }

        // If logged in and trying to access /home, allow it.
        if (loggedIn && targetPath == '/home') {
          debugPrint('GoRouter Redirect: Logged in and accessing /home, allowing access.');
          return null;
        }

        return null; // No redirect needed
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
      authNotifier.value = true;
      debugPrint('Auth status: Logged in as $role');
    } else {
      authNotifier.value = false;
      debugPrint('Auth status: Not logged in');
    }
  }

  @override
  void dispose() {
    // Only dispose if this MyApp is the owner of the ValueNotifier
    // Since it's global, it generally shouldn't be disposed here unless the entire app shuts down
    // authNotifier.dispose(); // Removed as it's global
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