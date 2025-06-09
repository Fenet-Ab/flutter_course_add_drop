import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

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
        debugPrint('Full login response data: $data');
        
        final token = data['token'] as String;
        final decoded = _decodeJwt(token);
        final role = decoded['role'] as String?;
        
        if (role == null) {
          throw Exception('Invalid token: role not found');
        }

        final prefs = await SharedPreferences.getInstance();
        
        // Clear any existing data first
        await prefs.clear();
        
        // Save new data with commit
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_role', role);
        await prefs.setString('user_username', username);
        await prefs.commit(); // Force commit changes
        
        // Verify the data was saved
        final savedToken = prefs.getString('jwt_token');
        final savedRole = prefs.getString('user_role');
        
        if (savedToken == null || savedRole == null) {
          throw Exception('Failed to save login credentials');
        }
        
        debugPrint('API Service: Token saved: $savedToken');
        debugPrint('API Service: Role saved: $savedRole');
        debugPrint('API Service: Username saved: $username');

        // Ensure data is persisted
        await Future.delayed(const Duration(milliseconds: 500));

        return {
          'token': token,
          'role': role,
          'username': username,
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

      debugPrint('Drop course request response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to request drop course: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Drop course request error: $e');
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
        Uri.parse('$baseUrl/admin/add/' + addId.toString() + '/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to approve add');
      }
    } catch (e) {
      debugPrint('Approve add error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token != null) {
        // Call backend logout endpoint
        final response = await http.get(
          Uri.parse('$baseUrl/logout'),
          headers: _getHeaders(token: token),
        );
        debugPrint('Backend logout response: ${response.statusCode} ${response.body}');

        if (response.statusCode == 200) {
          debugPrint('Logged out successfully - local tokens and user data cleared.');
          await prefs.clear();
        } else {
          debugPrint('Logout failed with status ${response.statusCode}: ${response.body}');
          throw Exception('Failed to logout');
        }
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<User> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      if (token == null) {
        throw Exception('No token found');
      }

      debugPrint('Making profile request with token: $token');
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Get user profile response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        // Instead of clearing token, return basic user info from token
        debugPrint('Received 401 from /profile API. Using token data instead.');
        final decoded = _decodeJwt(token);
        debugPrint('Decoded token data (error case): $decoded');
        
        // Create a basic user object from token data
        final user = User(
          id: decoded['id'] as int,
          username: prefs.getString('user_username') ?? '',
          password: '',
          email: '',
          fullName: '',
          role: decoded['role'] as String,
          profilePhoto: null,
        );
        debugPrint('Created user object from token (error case): ${user.toJson()}');
        return user;
      } else {
        throw Exception('Failed to get user profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Get user profile error: $e');
      // Instead of throwing, return basic user info from token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token != null) {
        final decoded = _decodeJwt(token);
        return User(
          id: decoded['id'] as int,
          username: prefs.getString('user_username') ?? '',
          password: '',
          email: '',
          fullName: '',
          role: decoded['role'] as String,
          profilePhoto: null,
        );
      }
      throw Exception('Session expired. Please log in again.');
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

  Future<List<Map<String, dynamic>>> getDropRequests() async {
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

      debugPrint('Get drop requests response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to fetch drop requests: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Get drop requests error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> updateDropRequest(String requestId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/drops/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'approval_status': status}),
      );

      debugPrint('Update drop request response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update drop request: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Update drop request error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> updateAddRequest(String requestId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/adds/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'approval_status': status}),
      );

      debugPrint('Update add request response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update add request: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Update add request error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String username,
    required String email,
    XFile? profilePhotoXFile,
    String? newPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      if (token == null) {
        throw Exception('No token found');
      }

      debugPrint('Updating profile with token: $token');
      
      // Create multipart request
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/auth/profile'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['full_name'] = fullName;
      request.fields['username'] = username;
      request.fields['email'] = email;
      if (newPassword != null && newPassword.isNotEmpty) {
        request.fields['password'] = newPassword;
      }

      // Add profile photo if provided
      if (profilePhotoXFile != null) {
        final bytes = await profilePhotoXFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_photo',
            bytes,
            filename: profilePhotoXFile.name,
          ),
        );
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Profile update response status: ${response.statusCode}');
      debugPrint('Profile update response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
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

  Map<String, String> _getHeaders({required String token}) {
    return {
      'Authorization': 'Bearer $token',
    };
  }
}