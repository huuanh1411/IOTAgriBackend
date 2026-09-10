/// Tuong ung Dtos/Auth/UserSummaryResponse.cs
class UserSummary {
  const UserSummary({
    required this.id,
    required this.email,
    required this.fullName,
  });

  final String id;
  final String email;
  final String fullName;

  factory UserSummary.fromJson(Map<String, dynamic> json) => UserSummary(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['fullName'] as String,
      );
}
