class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.age,
    required this.gender,
    this.interests = const [],
    this.profilePhotoPath,
  });

  final String name;
  final String email;
  final String password;
  final int age;
  final String gender;
  final List<String> interests;
  final String? profilePhotoPath;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'gender': gender,
        'interests': interests,
      };

  RegisterRequest copyWith({
    String? name,
    String? email,
    String? password,
    int? age,
    String? gender,
    List<String>? interests,
    String? profilePhotoPath,
  }) {
    return RegisterRequest(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
    );
  }
}
