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

  Map<String, dynamic> toJson() {
    // Backend expects `birth_date` (YYYY-MM-DD). We derive it from `age`
    // using today's month/day so the computed age matches what the user
    // entered. `interests` are persisted in a separate endpoint after
    // account creation — the /auth/register schema rejects them.
    final today = DateTime.now();
    final birth = DateTime(today.year - age, today.month, today.day);
    final birthDate =
        '${birth.year.toString().padLeft(4, '0')}-'
        '${birth.month.toString().padLeft(2, '0')}-'
        '${birth.day.toString().padLeft(2, '0')}';

    return {
      'full_name': name,
      'email': email,
      'password': password,
      'birth_date': birthDate,
      'gender': gender,
    };
  }

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
