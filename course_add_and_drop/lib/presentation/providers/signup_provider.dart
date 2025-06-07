import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:course_add_and_drop/data/model/signup_request.dart';
import 'package:course_add_and_drop/data/model/user.dart';
import 'package:course_add_and_drop/services/auth_services.dart';

class SignupState {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String? profilePhoto;
  final String role;
  final bool isLoading;
  final String? error;
  final bool isSignupSuccessful;

  SignupState({
    this.id = '',
    this.fullName = '',
    this.username = '',
    this.email = '',
    this.password = '',
    this.profilePhoto,
    this.role = 'Student',
    this.isLoading = false,
    this.error,
    this.isSignupSuccessful = false,
  });

  SignupState copyWith({
    String? id,
    String? fullName,
    String? username,
    String? email,
    String? password,
    String? profilePhoto,
    String? role,
    bool? isLoading,
    String? error,
    bool? isSignupSuccessful,
  }) {
    return SignupState(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSignupSuccessful: isSignupSuccessful ?? this.isSignupSuccessful,
    );
  }
}

class SignupNotifier extends StateNotifier<SignupState> {
  final AuthService _authService;

  SignupNotifier(this._authService) : super(SignupState());

  void updateId(String value) {
    state = state.copyWith(id: value, error: null);
  }

  void updateFullName(String value) {
    state = state.copyWith(fullName: value, error: null);
  }

  void updateUsername(String value) {
    state = state.copyWith(username: value, error: null);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value, error: null);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, error: null);
  }

  void updateProfilePhoto(String? value) {
    state = state.copyWith(profilePhoto: value, error: null);
  }

  void updateRole(String value) {
    state = state.copyWith(role: value, error: null);
  }

  bool validate() {
    if (state.id.isEmpty) {
      state = state.copyWith(error: 'ID is required');
      return false;
    }
    if (state.fullName.isEmpty) {
      state = state.copyWith(error: 'Full name is required');
      return false;
    }
    if (state.username.isEmpty) {
      state = state.copyWith(error: 'Username is required');
      return false;
    }
    if (state.password.length < 6) {
      state = state.copyWith(error: 'Password must be at least 6 characters');
      return false;
    }
    if (!state.email.contains('@')) {
      state = state.copyWith(error: 'Invalid email format');
      return false;
    }
    if (state.role != 'Student' && state.role != 'Registrar') {
      state = state.copyWith(error: 'Role must be Student or Registrar');
      return false;
    }
    return true;
  }

  Future<void> signup({required bool isTermsAccepted}) async {
    if (!isTermsAccepted) {
      state = state.copyWith(error: 'You must agree to the terms');
      return;
    }
    if (!validate()) return;

    try {
      state = state.copyWith(isLoading: true, error: null, isSignupSuccessful: false);
      
      final request = SignupRequest(
        id: int.parse(state.id),
        fullName: state.fullName,
        username: state.username,
        email: state.email,
        password: state.password,
        profilePhoto: state.profilePhoto,
        role: state.role,
      );
      
      await _authService.signup(request);
      
      if (!state.isLoading) return; // Check if the widget is still mounted
      
      state = state.copyWith(
        isLoading: false,
        isSignupSuccessful: true,
        error: null,
      );
    } catch (e) {
      if (!state.isLoading) return; // Check if the widget is still mounted
      
      state = state.copyWith(
        isLoading: false,
        isSignupSuccessful: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetForm() {
    state = SignupState();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final signupProvider = StateNotifierProvider<SignupNotifier, SignupState>((ref) {
  return SignupNotifier(ref.read(authServiceProvider));
});