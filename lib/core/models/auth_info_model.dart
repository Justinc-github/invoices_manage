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
      username: json['username'] ?? '未知用户名',
      email: json['email'] ?? '未知邮箱',
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      teamId: json['team_id'] ?? 0,
      teamName: json['team_name'] ?? '未知队伍',
      role: json['role'], // role 可以为 null
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
