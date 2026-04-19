import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    this.profilePhotoUrl,
    this.interests = const [],
    this.bio,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final int age;
  final String gender;
  final String? profilePhotoUrl;
  final List<String> interests;
  final String? bio;
  final DateTime? createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      profilePhotoUrl: json['profile_photo_url'] as String? ??
          json['avatar_url'] as String? ??
          json['photo'] as String?,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      bio: json['bio'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'age': age,
        'gender': gender,
        'profile_photo_url': profilePhotoUrl,
        'interests': interests,
        'bio': bio,
        'created_at': createdAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? gender,
    String? profilePhotoUrl,
    List<String>? interests,
    String? bio,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        age,
        gender,
        profilePhotoUrl,
        interests,
        bio,
        createdAt,
      ];
}
