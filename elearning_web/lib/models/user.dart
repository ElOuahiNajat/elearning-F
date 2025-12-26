class User {
	final String? id; // UUID
	final String firstName;
	final String lastName;
	final String email;
	final String role; // ADMIN or USER

	User({this.id, required this.firstName, required this.lastName, required this.email, required this.role});

	String get fullName => '$firstName $lastName'.trim();

	factory User.fromJson(Map<String, dynamic> json) => User(
				id: json['id']?.toString(),
				firstName: json['firstName'] as String? ?? '',
				lastName: json['lastName'] as String? ?? '',
				email: json['email'] as String? ?? '',
				role: json['role'] is String ? json['role'] as String : (json['role']?.toString() ?? 'USER'),
			);

	Map<String, dynamic> toJson({String? password}) {
		final map = <String, dynamic>{
			'firstName': firstName,
			'lastName': lastName,
			'email': email,
			'role': role,
		};
		if (password != null && password.isNotEmpty) map['password'] = password;
		return map;
	}
}

