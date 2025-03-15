import 'package:equatable/equatable.dart';

class AuthInfoModel extends Equatable {
  final int? id;
  final String? username;
  final String? email;
  final int? status;
  final String? createdAt;
  final int? teamId;
  final String? teamName;
  final String? role;

  const AuthInfoModel({
    required this.id,
    required this.username,
    required this.email,
    required this.status,
    required this.createdAt,
    required this.teamId,
    required this.teamName,
    required this.role,
  });

  factory AuthInfoModel.fromJson(Map<String, dynamic> json) {
    return AuthInfoModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      status: json['status'],
      createdAt: json['created_at'],
      teamId: json['team_id'],
      teamName: json['team_name'],
      role: json['role'],
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
    teamId,
    status,
  ];
}
