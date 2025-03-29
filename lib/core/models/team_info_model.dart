import 'package:equatable/equatable.dart';

class TeamInfoModel extends Equatable {
  final int id;
  final String name;
  final String headmanName;
  final List<TeamMember> members;

  const TeamInfoModel({
    required this.id,
    required this.name,
    required this.headmanName,
    required this.members,
  });

  factory TeamInfoModel.fromJson(Map<String, dynamic> json) {
    return TeamInfoModel(
      id: json['id'],
      name: json['name'],
      headmanName: json['headman_name'],
      members:
          (json['members'] as List)
              .map((member) => TeamMember.fromJson(member))
              .toList(),
    );
  }
  @override
  List<Object?> get props => [id, name, headmanName, members];
}

class TeamMember extends Equatable {
  final int userId;
  final String role;
  final String userName;
  final String avatar;

  const TeamMember({
    required this.userId,
    required this.role,
    required this.userName,
    required this.avatar,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: json['user_id'],
      role: json['role'] ?? '未知角色',
      userName: json['username'] ?? '未知用户名',
      avatar: json['avatar'] ?? '',
    );
  }

  @override
  List<Object?> get props => [userId, role, userName, avatar];
}

class TeamUserIdsModel extends Equatable {
  final int? teamId;
  final int? captainId;
  final List<int>? userIds;

  const TeamUserIdsModel({
    required this.teamId,
    required this.captainId,
    required this.userIds,
  });

  /// JSON 数据转换为模型对象
  factory TeamUserIdsModel.fromJson(Map<String, dynamic> json) {
    return TeamUserIdsModel(
      teamId: json['team_id'],
      captainId: json['captain_id'],
      userIds:
          (json['user_ids'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  /// 转换模型为 JSON 格式
  Map<String, dynamic> toJson() {
    return {'team_id': teamId, 'captain_id': captainId, 'user_ids': userIds};
  }

  @override
  List<Object?> get props => [teamId, captainId, userIds];
}
