import 'package:flutter_test/flutter_test.dart';
import 'package:course_add_and_drop/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late ApiService apiService;
  late http.Client mockClient;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService();
  });

  group('ApiService Tests', () {
    test('login should return user data on successful login', () async {
      // Arrange
      const username = 'testuser';
      const password = 'testpass';
      final expectedResponse = {
        'username': 'testuser',
        'role': 'Student',
        'token': 'test_token'
      };

      when(mockClient.post(
        Uri.parse('http://localhost:3000/api/auth/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '{"username": "testuser", "role": "Student", "token": "test_token"}',
        200,
      ));

      // Act
      final result = await apiService.login(username, password);

      // Assert
      expect(result['username'], equals('testuser'));
      expect(result['role'], equals('Student'));
      expect(result['token'], equals('test_token'));
    });

    test('getUserProfile should return user profile data', () async {
      // Arrange
      final expectedUser = {
        'id': 1,
        'username': 'testuser',
        'fullName': 'Test User',
        'email': 'test@example.com',
        'role': 'Student'
      };

      when(mockClient.get(
        Uri.parse('http://localhost:3000/api/users/profile'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        '{"id": 1, "username": "testuser", "fullName": "Test User", "email": "test@example.com", "role": "Student"}',
        200,
      ));

      // Act
      final result = await apiService.getUserProfile();

      // Assert
      expect(result.id, equals(1));
      expect(result.username, equals('testuser'));
      expect(result.fullName, equals('Test User'));
      expect(result.email, equals('test@example.com'));
      expect(result.role, equals('Student'));
    });
  });
} 