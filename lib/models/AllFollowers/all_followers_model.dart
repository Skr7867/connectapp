class AllFollowersModel {
  List<Followers>? followers;

  AllFollowersModel({this.followers});

  AllFollowersModel.fromJson(Map<String, dynamic> json) {
    if (json['followers'] != null) {
      followers = <Followers>[];
      json['followers'].forEach((v) {
        followers!.add(Followers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (followers != null) {
      data['followers'] = followers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Followers {
  String? sId;
  Follower? follower;
  String? following;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Followers(
      {this.sId,
      this.follower,
      this.following,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Followers.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    follower = json['follower'] != null
        ? Follower.fromJson(json['follower'])
        : null;
    following = json['following'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (follower != null) {
      data['follower'] = follower!.toJson();
    }
    data['following'] = following;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Follower {
  String? sId;
  String? fullName;
  String? username;
  Avatar? avatar;
  String? id;

  Follower({this.sId, this.fullName, this.username, this.avatar, this.id});

  Follower.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    avatar =
        json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['imageUrl'] = imageUrl;
    return data;
  }
}
