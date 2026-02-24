class AppUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double averageRating;
  final int totalReviews;

  const AppUser({
    required this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber,
    this.profileImageUrl,
    this.dateOfBirth,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  String get fullName => '$firstName $lastName'.trim();

  bool get hasCompletedProfile =>
      firstName.isNotEmpty && lastName.isNotEmpty;

  /// Kreira novog korisnika sa default vrijednostima
  factory AppUser.fromAuth({
    required String id,
    required String email,
  }) {
    final now = DateTime.now();
    return AppUser(
      id: id,
      email: email,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Konverzija iz Firestore dokumenta
  factory AppUser.fromFirestore(Map<String, dynamic> map, String docId) {
    return AppUser(
      id: docId,
      email: map['email'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'] as String)
          : null,
      gender: map['gender'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: map['totalReviews'] as int? ?? 0,
    );
  }

  /// Konverzija u Firestore mapu
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'averageRating': averageRating,
      'totalReviews': totalReviews,
    };
  }
}
