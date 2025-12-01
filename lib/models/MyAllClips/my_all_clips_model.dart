class MyAllClipsModel {
  String? message;
  List<Clips>? clips;

  MyAllClipsModel({this.message, this.clips});

  MyAllClipsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['clips'] != null) {
      clips = <Clips>[];
      json['clips'].forEach((v) {
        clips!.add(Clips.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    if (clips != null) {
      data['clips'] = clips!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Clips {
  String? sId;
  String? userId;
  String? clipId;
  String? caption;
  List<String>? tags;
  String? status;
  bool? isPrivate;
  String? createdAt;
  int? iV;
  String? originalFileName;
  String? processedKey;
  String? processedUrl;
  String? thumbnailKey;
  String? thumbnailUrl;
  int? likeCount;
  int? commentCount;
  int? viewCount;
  String? id;
  List<Comments>? comments;

  Clips({
    this.sId,
    this.userId,
    this.clipId,
    this.caption,
    this.tags,
    this.status,
    this.isPrivate,
    this.createdAt,
    this.iV,
    this.originalFileName,
    this.processedKey,
    this.processedUrl,
    this.thumbnailKey,
    this.thumbnailUrl,
    this.likeCount,
    this.commentCount,
    this.viewCount,
    this.id,
    this.comments,
  });

  Clips.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    clipId = json['clipId'];
    caption = json['caption'];
    tags = json['tags'] != null ? List<String>.from(json['tags']) : [];
    status = json['status'];
    isPrivate = json['isPrivate'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    originalFileName = json['originalFileName'];
    processedKey = json['processedKey'];
    processedUrl = json['processedUrl'];
    thumbnailKey = json['thumbnailKey'];
    thumbnailUrl = json['thumbnailUrl'];
    likeCount = json['likeCount'] ?? 0;
    commentCount = json['commentCount'] ?? 0;
    viewCount = json['viewCount'] ?? 0;
    id = json['id'];
    if (json['comments'] != null) {
      comments = <Comments>[];
      json['comments'].forEach((v) {
        comments!.add(Comments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['userId'] = userId;
    data['clipId'] = clipId;
    data['caption'] = caption;
    data['tags'] = tags;
    data['status'] = status;
    data['isPrivate'] = isPrivate;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    data['originalFileName'] = originalFileName;
    data['processedKey'] = processedKey;
    data['processedUrl'] = processedUrl;
    data['thumbnailKey'] = thumbnailKey;
    data['thumbnailUrl'] = thumbnailUrl;
    data['likeCount'] = likeCount;
    data['commentCount'] = commentCount;
    data['viewCount'] = viewCount;
    data['id'] = id;
    if (comments != null) {
      data['comments'] = comments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Comments {
  String? sId;
  String? clipId;
  UserId? userId;
  String? content;
  dynamic parentCommentId;
  List<dynamic>? likes;
  String? createdAt;
  int? iV;
  List<dynamic>? replies;

  Comments({
    this.sId,
    this.clipId,
    this.userId,
    this.content,
    this.parentCommentId,
    this.likes,
    this.createdAt,
    this.iV,
    this.replies,
  });

  Comments.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    clipId = json['clipId'];
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    content = json['content'];
    parentCommentId = json['parentCommentId'];
    likes = json['likes'] != null ? List<dynamic>.from(json['likes']) : [];
    createdAt = json['createdAt'];
    iV = json['__v'];
    replies =
        json['replies'] != null ? List<dynamic>.from(json['replies']) : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['clipId'] = clipId;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['content'] = content;
    data['parentCommentId'] = parentCommentId;
    data['likes'] = likes;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    data['replies'] = replies;
    return data;
  }
}

class UserId {
  String? sId;
  String? fullName;
  String? username;
  Avatar? avatar;
  String? id;

  UserId({this.sId, this.fullName, this.username, this.avatar, this.id});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    data['id'] = id;
    return data;
  }
}

class Avatar {
  String? sId;
  String? imageUrl;

  Avatar({this.sId, this.imageUrl});

  Avatar.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['imageUrl'] = imageUrl;
    return data;
  }
}
