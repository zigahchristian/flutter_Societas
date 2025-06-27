class User {
  final int? id; // Optional for created users
  final String firstname;
  final String lastname;
  final String email;
  final String? password; // Required for signup/login only

  User({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.password,
  });

  /// Convert from JSON (e.g. from API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
    );
  }

  /// Convert to JSON (e.g. for POST or PUT request)
  Map<String, dynamic> toJson({bool includePassword = false}) {
    final data = {
      if (id != null) 'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
    };
    if (includePassword && password != null) {
      data['password'] = password;
    }
    return data;
  }

  String get fullName => '$firstname $lastname';
}
