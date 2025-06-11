import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:course_add_and_drop/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MockClient extends Mock implements http.Client {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late ApiService apiService;
  late MockClient mockClient;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockClient = MockClient();
    mockPrefs = MockSharedPreferences();
    apiService = ApiService();
  });

  group('Login Tests', () {
    test('successful login returns user data', () async {
      // Arrange
      final mockResponse = {
        'token': 'mock_token',
        'role': 'Student',
        'username': 'testuser'
      };

      when(mockPrefs.setString('jwt_token', 'mock_token'))
          .thenAnswer((_) async => true);
      when(mockPrefs.setString('user_role', 'Student'))
          .thenAnswer((_) async => true);
      when(mockPrefs.setString('user_username', 'testuser'))
          .thenAnswer((_) async => true);
      when(mockPrefs.getString('jwt_token'))
          .thenReturn('mock_token');
      when(mockPrefs.getString('user_role'))
          .thenReturn('Student');

      // Act
      final result = await apiService.login('testuser', 'password');

      // Assert
      expect(result['token'], equals('mock_token'));
      expect(result['role'], equals('Student'));
      expect(result['username'], equals('testuser'));
    });

    test('login throws exception on invalid credentials', () async {
      // Act & Assert
      expect(
        () => apiService.login('wronguser', 'wrongpass'),
        throwsException,
      );
    });
  });

  group('Course Tests', () {
    test('getCourses returns list of courses', () async {
      // Arrange
      final mockCourses = [
        {
          'id': 1,
          'title': 'Test Course',
          'code': 'TEST101',
          'description': 'Test Description',
          'credit_hours': '3'
        }
      ];

      when(mockPrefs.getString('jwt_token'))
          .thenReturn('mock_token');

      // Act
      final result = await apiService.getCourses();

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('createCourse creates new course', () async {
      // Arrange
      when(mockPrefs.getString('jwt_token'))
          .thenReturn('mock_token');

      // Act
      final result = await apiService.createCourse(
        title: 'New Course',
        code: 'NEW101',
        description: 'New Description',
        creditHours: '3',
      );

      // Assert
      expect(result, isA<Map<String, dynamic>>());
    });
  });

  group('Add/Drop Tests', () {
    test('getAdds returns list of add requests', () async {
      // Arrange
      when(mockPrefs.getString('jwt_token'))
          .thenReturn('mock_token');

      // Act
      final result = await apiService.getAdds();

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('getDrops returns list of drop requests', () async {
      // Arrange
      when(mockPrefs.getString('jwt_token'))
          .thenReturn('mock_token');

      // Act
      final result = await apiService.getDrops();

      // Assert
      expect(result, isA<List<Map<String, dynamic>>>());
    });
  });
} 