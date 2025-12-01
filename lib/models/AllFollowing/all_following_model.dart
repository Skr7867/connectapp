class AllFollowingModel {
  List<Following>? following;

  AllFollowingModel({this.following});

  AllFollowingModel.fromJson(Map<String, dynamic> json) {
    if (json['following'] != null) {
      following = <Following>[];
      json['following'].forEach((v) {
        following!.add(Following.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (following != null) {
      data['following'] = following!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Following {
  String? sId;
  String? follower;
  Followings? following; // Changed from Following? to Followings?
  String? createdAt;
  String? updatedAt;
  int? iV;

  Following(
      {this.sId,
      this.follower,
      this.following,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Following.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    follower = json['follower'];
    following = json['following'] != null
        ? Followings.fromJson(
            json['following']) // Changed to Followings.fromJson
        : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['follower'] = follower;
    if (following != null) {
      data['following'] =
          following!.toJson(); // Now calls Followings.toJson
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Followings {
  String? sId;
  String? fullName;
  Avatar? avatar;
  String? username;
  String? id;

  Followings({this.sId, this.fullName, this.avatar, this.username, this.id});

  Followings.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    avatar =
        json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    username = json['username'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    data['username'] = username;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['imageUrl'] = imageUrl;
    return data;
  }
}
