import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      return 'http://10.0.2.2:5000/api';
    }
  }

  Future<Map<String, dynamic>> signUp(User user, File? photo) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/signup'));
      request.fields.addAll(user.toJson().map((key, value) => MapEntry(key, value.toString())));
      if (photo != null) {
        request.files.add(await http.MultipartFile.fromPath('profile_photo', photo.path));
      }

      debugPrint('Sending signup request: ${user.toJson()}');
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      debugPrint('Sign-up response: ${response.statusCode} ${responseBody.body}');
      if (response.statusCode == 201) {
        return jsonDecode(responseBody.body);
      } else {
        final error = jsonDecode(responseBody.body)['error'] ?? 'Sign-up failed: ${response.statusCode}';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Sign-up error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> checkIdAvailability(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/auth/check-id/$id'));
      debugPrint('Check ID $id response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'available': data['available'] ?? false,
          'role': data['role'],
          'error': data['error'],
        };
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to check ID: ${response.statusCode}';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Check ID error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      debugPrint('Attempting login to: $baseUrl/auth/login');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timed out. Please check if the server is running.');
        },
      );

      debugPrint('Login response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;
        final decoded = _decodeJwt(token);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return {
          'token': token,
          'role': decoded['role'] as String?,
        };
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Could not connect to the server. Please check if the server is running.');
    } on http.ClientException catch (e) {
      throw Exception('Failed to connect to the server: ${e.message}');
    } catch (e) {
      debugPrint('Login error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      debugPrint('Forgot password response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return {'message': 'Password reset instructions sent'};
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to send reset instructions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Forgot password error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> createCourse({
    required String title,
    required String code,
    required String description,
    required String creditHours,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/courses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'code': code,
          'description': description,
          'credit_hours': creditHours,
        }),
      );

      debugPrint('Create course response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to create course: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Create course error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/courses'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get courses response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch courses: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Get courses error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<Map<String, dynamic>>> getAdds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/adds'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get adds response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch adds: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Get adds error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> addCourse(int courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/adds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'course_id': courseId}),
      );

      debugPrint('Add course response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to add course: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Add course error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> dropCourse(int addId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/drops'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'add_id': addId}),
      );

      debugPrint('Drop course response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to drop course: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Drop course error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> approveAdd(int addId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/adds/$addId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'approval_status': status}),
      );

      debugPrint('Approve add response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update add: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Approve add error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    debugPrint('Token cleared on logout');
  }

  Future<User> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final decoded = _decodeJwt(token);
      debugPrint('Decoded token: $decoded');
      
      return User(
        id: int.parse(decoded['id']?.toString() ?? '0'),
        username: decoded['username']?.toString() ?? '',
        fullName: decoded['fullName']?.toString() ?? decoded['username']?.toString() ?? '',
        email: decoded['email']?.toString() ?? '',
        role: decoded['role']?.toString() ?? 'Student',
        password: '', // Password not stored in token
      );
    } catch (e) {
      debugPrint('Get user profile error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> requestDrop(int addId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/drops'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'add_id': addId}),
      );

      debugPrint('Request drop response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to request drop: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Request drop error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<List<Map<String, dynamic>>> getDrops() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/drops'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Get drops response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch dropped courses: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Get drops error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> deleteCourse(String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/courses/$courseId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Delete course response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to delete course: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Delete course error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> updateCourse(String courseId, Map<String, dynamic> updatedData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/courses/$courseId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedData),
      );

      debugPrint('Update course response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update course: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Update course error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token');
      }
      final payload = parts[1];
      final decoded = base64Url.decode(base64Url.normalize(payload));
      return jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('JWT decode error: $e');
      throw Exception('Failed to decode token');
    }
  }
}