import 'package:equatable/equatable.dart';

class AuthInfoModel extends Equatable {
  final String username;
  final String email;
  final String teamName;
  final String role;
  final String createdAt;
  final int status;
  final int id;

  const AuthInfoModel({
    required this.username,
    required this.email,
    required this.teamName,
    required this.role,
    required this.createdAt,
    required this.status,
    required this.id,
  });

  factory AuthInfoModel.fromJson(Map<String, dynamic> json) {
    return AuthInfoModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      teamName: json['team_name'],
      role: json['role'],
      createdAt: json['created_at'],
      status: json['status'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    teamName,
    role,
    createdAt,
    status,
  ];
}
