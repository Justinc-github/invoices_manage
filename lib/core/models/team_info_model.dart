class TeamInfoModel {
  final int id;
  final String name;
  final String headmanName;
  final List<TeamMember> members;

  TeamInfoModel({
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
}

class TeamMember {
  final int userId;
  final String role;
  final String userName;
  final String avatar;

  TeamMember({
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
}
