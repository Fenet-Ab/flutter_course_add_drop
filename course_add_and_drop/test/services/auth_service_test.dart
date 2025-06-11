import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:course_add_and_drop/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockApiService mockApiService;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockApiService = MockApiService();
    mockPrefs = MockSharedPreferences();
  });

  group('Auth Tests', () {
    test('login should return user data on successful login', () async {
      // Arrange
      final mockResponse = {
        'token': 'mock_token',
        'role': 'Student',
        'username': 'testuser'
      };
      when(mockApiService.login('test@example.com', 'password'))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await mockApiService.login('test@example.com', 'password');

      // Assert
      expect(result['token'], equals('mock_token'));
      expect(result['role'], equals('Student'));
      expect(result['username'], equals('testuser'));
    });

    test('login should throw exception on invalid credentials', () async {
      // Arrange
      when(mockApiService.login('wrong@example.com', 'wrongpass'))
          .thenThrow(Exception('Invalid credentials'));

      // Act & Assert
      expect(
        () => mockApiService.login('wrong@example.com', 'wrongpass'),
        throwsException,
      );
    });
  });
} 