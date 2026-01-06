/// media : [{"_id":"68ea308deca706f6ba17fe0d","content":"https://connect-app-bucket2.s3.us-east-1.amazonaws.com/Chat/messageFile-1760178315330-641973123.jpg","createdAt":"2025-10-11T10:25:17.501Z"}]
library;

class UserProfileMediaListModel {
  final List<Media> media;

  UserProfileMediaListModel({required this.media});

  factory UserProfileMediaListModel.fromJson(Map<String, dynamic> json) {
    return UserProfileMediaListModel(
      media: json['media'] != null
          ? List<Media>.from(json['media'].map((v) => Media.fromJson(v)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media': media.map((v) => v.toJson()).toList(),
    };
  }

  UserProfileMediaListModel copyWith({List<Media>? media}) {
    return UserProfileMediaListModel(
      media: media ?? this.media,
    );
  }

  @override
  String toString() => 'UserProfileMediaListModel(media: $media)';
}

/// _id : "68ea308deca706f6ba17fe0d"
/// content : "https://connect-app-bucket2.s3.us-east-1.amazonaws.com/Chat/messageFile-1760178315330-641973123.jpg"
/// createdAt : "2025-10-11T10:25:17.501Z"

class Media {
  final String id;
  final String content;
  final String createdAt;

  Media({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'content': content,
      'createdAt': createdAt,
    };
  }

  Media copyWith({
    String? id,
    String? content,
    String? createdAt,
  }) {
    return Media(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Media(id: $id, content: $content, createdAt: $createdAt)';
}
