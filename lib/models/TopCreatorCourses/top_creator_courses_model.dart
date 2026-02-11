class TopCreatorCoursesModel {
  bool? success;
  String? message;
  Data? data;

  TopCreatorCoursesModel({this.success, this.message, this.data});

  TopCreatorCoursesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? creatorId;
  int? reviewCount;
  double? avgRating;
  int? courseCount;
  int? totalScore;
  Creator? creator;
  List<Courses>? courses;

  Data(
      {this.creatorId,
      this.reviewCount,
      this.avgRating,
      this.courseCount,
      this.totalScore,
      this.creator,
      this.courses});

  Data.fromJson(Map<String, dynamic> json) {
    creatorId = json['creatorId'];
    reviewCount = json['reviewCount'];
    avgRating = (json['avgRating'] != null)
        ? (json['avgRating'] is int
            ? (json['avgRating'] as int).toDouble()
            : json['avgRating'] as double)
        : null;
    courseCount = json['courseCount'];
    totalScore = json['totalScore'];
    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;
    if (json['courses'] != null) {
      courses = <Courses>[];
      json['courses'].forEach((v) {
        courses!.add(Courses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['creatorId'] = creatorId;
    data['reviewCount'] = reviewCount;
    data['avgRating'] = avgRating;
    data['courseCount'] = courseCount;
    data['totalScore'] = totalScore;
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    if (courses != null) {
      data['courses'] = courses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Creator {
  String? sId;
  String? fullName;
  String? email;
  Avatar? avatar;
  String? id;

  Creator({this.sId, this.fullName, this.email, this.avatar, this.id});

  Creator.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    avatar = json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['email'] = email;
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

class Courses {
  String? sId;
  String? title;
  String? description;
  String? thumbnail;
  bool? isPublished;
  int? coins;
  String? createdAt;
  bool? isEnrolled;

  Courses(
      {this.sId,
      this.title,
      this.description,
      this.thumbnail,
      this.isPublished,
      this.coins,
      this.createdAt,
      this.isEnrolled});

  Courses.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    isPublished = json['isPublished'];
    coins = json['coins'];
    createdAt = json['createdAt'];
    isEnrolled = json['isEnrolled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['thumbnail'] = thumbnail;
    data['isPublished'] = isPublished;
    data['coins'] = coins;
    data['createdAt'] = createdAt;
    data['isEnrolled'] = isEnrolled;
    return data;
  }
}
