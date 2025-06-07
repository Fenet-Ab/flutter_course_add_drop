class User {
  final int id;
  final String username;
  final String password;
  final String email;
  final String fullName;
  final String role;
  final String? profilePhoto;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
    required this.role,
    this.profilePhoto,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      profilePhoto: json['profile_photo'] as String?,
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? fullName,
    String? role,
    String? profilePhoto,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'full_name': fullName,
      'role': role,
      'profile_photo': profilePhoto,
    };
  }
}