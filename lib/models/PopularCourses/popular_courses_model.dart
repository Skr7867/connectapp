class PopularCourseModel {
  bool? success;
  List<Data>? data;
  Pagination? pagination;

  PopularCourseModel({this.success, this.data, this.pagination});

  PopularCourseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Data {
  String? courseId;
  String? title;
  String? description;
  String? thumbnail;
  int? enrolledCount;
  int? coins;
  Creator? creator;
  Ratings? ratings;
  bool? isEnrolled;

  Data(
      {this.courseId,
      this.title,
      this.description,
      this.thumbnail,
      this.enrolledCount,
      this.coins,
      this.creator,
      this.ratings,
      this.isEnrolled});

  Data.fromJson(Map<String, dynamic> json) {
    courseId = json['courseId'];
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    enrolledCount = json['enrolledCount'];
    coins = json['coins'];
    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;
    ratings =
        json['ratings'] != null ? Ratings.fromJson(json['ratings']) : null;
    isEnrolled = json['isEnrolled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['courseId'] = courseId;
    data['title'] = title;
    data['description'] = description;
    data['thumbnail'] = thumbnail;
    data['enrolledCount'] = enrolledCount;
    data['coins'] = coins;
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    if (ratings != null) {
      data['ratings'] = ratings!.toJson();
    }
    data['isEnrolled'] = isEnrolled;
    return data;
  }
}

class Creator {
  String? id;
  String? name;
  String? email;
  String? avatar;

  Creator({this.id, this.name, this.email, this.avatar});

  Creator.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['avatar'] = avatar;
    return data;
  }
}

class Ratings {
  double? avgRating;
  int? totalReviews;

  Ratings({this.avgRating, this.totalReviews});

  Ratings.fromJson(Map<String, dynamic> json) {
    avgRating = (json['avgRating'] != null)
        ? (json['avgRating'] as num).toDouble()
        : 0.0;
    totalReviews = json['totalReviews'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['avgRating'] = avgRating;
    data['totalReviews'] = totalReviews;
    return data;
  }
}

class Pagination {
  int? totalCourses;
  int? currentPage;
  int? totalPages;
  int? limit;

  Pagination(
      {this.totalCourses, this.currentPage, this.totalPages, this.limit});

  Pagination.fromJson(Map<String, dynamic> json) {
    totalCourses = json['totalCourses'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCourses'] = totalCourses;
    data['currentPage'] = currentPage;
    data['totalPages'] = totalPages;
    data['limit'] = limit;
    return data;
  }
}
