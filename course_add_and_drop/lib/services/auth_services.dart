import 'package:dio/dio.dart';
import 'package:course_add_and_drop/data/model/signup_request.dart';
import 'package:course_add_and_drop/data/model/user.dart';
import 'package:course_add_and_drop/core/network/dio_client.dart';

class AuthService {
  final Dio _dio = DioClient.instance;

  Future<User> signup(SignupRequest request) async {
    try {
      final response = await _dio.post('/auth/signup', data: request.toJson());
      
      // Check if the response contains a success message
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('message') && data['message'] == 'User registered successfully') {
          // If we have a success message, return a User object
          return User(
            id: 0, // The actual ID will be set after login
            fullName: request.fullName,
            username: request.username,
            password: request.password,
            email: request.email,
            role: request.role,
            profilePhoto: request.profilePhoto,
          );
        }
      }
      
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timed out. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server. Please check if the server is running.');
      } else if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
          throw Exception(errorData['error']);
        } else if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('Signup failed: ${e.response?.statusMessage ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Signup failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<User> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timed out. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server. Please check if the server is running.');
      } else if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
          throw Exception(errorData['error']);
        } else if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('Login failed: ${e.response?.statusMessage ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timed out. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Could not connect to the server. Please check if the server is running.');
      } else if (e.response != null) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
          throw Exception(errorData['error']);
        } else if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        } else {
          throw Exception('Password reset failed: ${e.response?.statusMessage ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Password reset failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}