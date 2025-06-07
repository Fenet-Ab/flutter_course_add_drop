import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_request.freezed.dart';
part 'signup_request.g.dart';

@freezed
class SignupRequest with _$SignupRequest {
  const factory SignupRequest({
    required int id,
    @JsonKey(name: 'full_name') required String fullName,
    required String username,
    required String email,
    required String password,
    @Default('Student') String role,
    String? profilePhoto,
  }) = _SignupRequest;

  factory SignupRequest.fromJson(Map<String, dynamic> json) => _$SignupRequestFromJson(json);
}