class EnrollResponse {
  final bool success;
  final String message;
  final Space? space;
  EnrollResponse({
    required this.success,
    required this.message,
    this.space,
  });

  factory EnrollResponse.fromJson(Map<String, dynamic> json) {
    return EnrollResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      space: json['space'] != null ? Space.fromJson(json['space']) : null,
    );
  }
}

class Space {
  final String? id;
  final String? title;
  final String? description;
  final String? creator;
  final String? status;
  final String? startTime;
  final int? totalJoined;
  final List<String>? tags;
  final List<Member>? members;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  Space({
    this.id,
    this.title,
    this.description,
    this.creator,
    this.status,
    this.startTime,
    this.totalJoined,
    this.tags,
    this.members,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      creator: json['creator'],
      status: json['status'],
      startTime: json['startTime'],
      totalJoined: json['totalJoined'],
      tags: List<String>.from(json['tags'] ?? []),
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => Member.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class Member {
  final String? user;
  final String? role;
  final bool? kicked;
  final String? id;
  final String? joinedAt;

  Member({
    this.user,
    this.role,
    this.kicked,
    this.id,
    this.joinedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      user: json['user'],
      role: json['role'],
      kicked: json['kicked'],
      id: json['_id'],
      joinedAt: json['joinedAt'],
    );
  }
}
