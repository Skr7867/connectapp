class AllUsersClipsModel {
  String? message;
  List<Clips>? clips;

  AllUsersClipsModel({this.message, this.clips});

  AllUsersClipsModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['clips'] != null) {
      clips = <Clips>[];
      json['clips'].forEach((v) {
        clips!.add(Clips.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
  List<Comments>? comments;

  Clips(
      {this.sId,
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
      this.comments});

  Clips.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    clipId = json['clipId'];
    caption = json['caption'];
    tags = json['tags'].cast<String>();
    status = json['status'];
    isPrivate = json['isPrivate'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    originalFileName = json['originalFileName'];
    processedKey = json['processedKey'];
    processedUrl = json['processedUrl'];
    thumbnailKey = json['thumbnailKey'];
    thumbnailUrl = json['thumbnailUrl'];
    if (json['comments'] != null) {
      comments = <Comments>[];
      json['comments'].forEach((v) {
        comments!.add(Comments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
  String? parentCommentId;
  List<String>? likes; // ✅ fix: no more Null type
  String? createdAt;
  int? iV;
  List<Replies>? replies;

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
    if (json['likes'] != null) {
      likes = List<String>.from(json['likes']); // ✅ parse safely
    }
    createdAt = json['createdAt'];
    iV = json['__v'];
    if (json['replies'] != null) {
      replies =
          (json['replies'] as List).map((v) => Replies.fromJson(v)).toList();
    }
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
    if (likes != null) {
      data['likes'] = likes; // ✅ safe
    }
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    if (replies != null) {
      data['replies'] = replies!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Replies {
  String? sId;
  String? clipId;
  UserId? userId;
  String? content;
  String? parentCommentId;
  List<String>? likes; // ✅ same fix
  String? createdAt;
  int? iV;

  Replies({
    this.sId,
    this.clipId,
    this.userId,
    this.content,
    this.parentCommentId,
    this.likes,
    this.createdAt,
    this.iV,
  });

  Replies.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    clipId = json['clipId'];
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    content = json['content'];
    parentCommentId = json['parentCommentId'];
    if (json['likes'] != null) {
      likes = List<String>.from(json['likes']); // ✅ safe
    }
    createdAt = json['createdAt'];
    iV = json['__v'];
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
    if (likes != null) {
      data['likes'] = likes;
    }
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}

class UserId {
  String? sId;
  String? fullName;
  String? username;
  Avatar? avatar;

  UserId({this.sId, this.fullName, this.username, this.avatar});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    avatar =
        json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['imageUrl'] = imageUrl;
    return data;
  }
}
