class GetAllSpacesModel {
  bool? success;
  List<Spaces>? spaces;

  GetAllSpacesModel({this.success, this.spaces});

  GetAllSpacesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['spaces'] != null) {
      spaces = <Spaces>[];
      json['spaces'].forEach((v) {
        spaces!.add(Spaces.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (spaces != null) {
      data['spaces'] = spaces!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Spaces {
  String? sId;
  String? title;
  String? description;
  Creator? creator;
  String? status;
  String? startTime;
  int? totalJoined;
  List<String>? tags;
  List<dynamic>? members;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Spaces({
    this.sId,
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
    this.iV,
  });

  Spaces.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;
    status = json['status'];
    startTime = json['startTime'];
    totalJoined = json['totalJoined'];
    tags = json['tags'] != null ? List<String>.from(json['tags']) : null;

    members =
        json['members'] != null ? List<dynamic>.from(json['members']) : null;

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    data['status'] = status;
    data['startTime'] = startTime;
    data['totalJoined'] = totalJoined;
    data['tags'] = tags;

    if (members != null) {
      data['members'] = members;
    }

    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Creator {
  SocialLinks? socialLinks;
  String? sId;
  String? fullName;
  String? username;
  String? email;
  Avatar? avatar;

  Creator(
      {this.socialLinks,
      this.sId,
      this.fullName,
      this.username,
      this.email,
      this.avatar});

  Creator.fromJson(Map<String, dynamic> json) {
    socialLinks = json['socialLinks'] != null
        ? SocialLinks.fromJson(json['socialLinks'])
        : null;
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (socialLinks != null) {
      data['socialLinks'] = socialLinks!.toJson();
    }
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    data['email'] = email;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    return data;
  }
}

class SocialLinks {
  String? instagram;
  String? twitter;
  String? linkedin;
  String? website;

  SocialLinks({this.instagram, this.twitter, this.linkedin, this.website});

  SocialLinks.fromJson(Map<String, dynamic> json) {
    instagram = json['instagram'];
    twitter = json['twitter'];
    linkedin = json['linkedin'];
    website = json['website'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instagram'] = instagram;
    data['twitter'] = twitter;
    data['linkedin'] = linkedin;
    data['website'] = website;
    return data;
  }
}

class Avatar {
  String? sId;
  String? name;
  String? imageUrl;
  bool? isActive;
  int? coins;
  int? iV;

  Avatar(
      {this.sId, this.name, this.imageUrl, this.isActive, this.coins, this.iV});

  Avatar.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    isActive = json['isActive'];
    coins = json['coins'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['imageUrl'] = imageUrl;
    data['isActive'] = isActive;
    data['coins'] = coins;
    data['__v'] = iV;
    return data;
  }
}
