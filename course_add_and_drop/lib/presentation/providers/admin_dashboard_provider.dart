import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_add_and_drop/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardState {
  final String? token;
  final String successMessage;
  final String errorMessage;
  final bool isLoading;
  final List<Map<String, dynamic>> adds;
  final String adminName;
  final String? userRole;
  final String? userName;

  AdminDashboardState({
    this.token,
    this.successMessage = '',
    this.errorMessage = '',
    this.isLoading = true,
    this.adds = const [],
    this.adminName = '',
    this.userRole,
    this.userName,
  });

  AdminDashboardState copyWith({
    String? token,
    String? successMessage,
    String? errorMessage,
    bool? isLoading,
    List<Map<String, dynamic>>? adds,
    String? adminName,
    String? userRole,
    String? userName,
  }) {
    return AdminDashboardState(
      token: token ?? this.token,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      adds: adds ?? this.adds,
      adminName: adminName ?? this.adminName,
      userRole: userRole ?? this.userRole,
      userName: userName ?? this.userName,
    );
  }
}

class AdminDashboardNotifier extends StateNotifier<AdminDashboardState> {
  final ApiService _apiService;

  AdminDashboardNotifier(this._apiService) : super(AdminDashboardState());

  Future<void> loadData() async {
    try {
      final user = await _apiService.getUserProfile();
      final adds = await _apiService.getAdds();
      
      state = state.copyWith(
        adminName: user.fullName,
        adds: adds,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  Future<void> createCourse({
    required String title,
    required String code,
    required String description,
    required String creditHours,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '', successMessage: '');
      
      final response = await _apiService.createCourse(
        title: title,
        code: code,
        description: description,
        creditHours: creditHours,
      );

      state = state.copyWith(
        successMessage: response['message'] ?? 'Course created successfully',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  Future<void> loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      userRole: prefs.getString('user_role'),
    );
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      userName: prefs.getString('user_name'),
    );
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final adminDashboardProvider = StateNotifierProvider<AdminDashboardNotifier, AdminDashboardState>((ref) {
  return AdminDashboardNotifier(ref.read(apiServiceProvider));
}); 