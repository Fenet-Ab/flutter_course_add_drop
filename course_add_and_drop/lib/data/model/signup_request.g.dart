// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignupRequestImpl _$$SignupRequestImplFromJson(Map<String, dynamic> json) =>
    _$SignupRequestImpl(
      id: (json['id'] as num).toInt(),
      fullName: json['full_name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      role: json['role'] as String? ?? 'Student',
      profilePhoto: json['profilePhoto'] as String?,
    );

Map<String, dynamic> _$$SignupRequestImplToJson(_$SignupRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'role': instance.role,
      'profilePhoto': instance.profilePhoto,
    };
