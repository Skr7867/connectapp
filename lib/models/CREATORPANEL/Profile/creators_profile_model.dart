class CreatorProfileModel {
  Creator? creator;
  Stats? stats;

  CreatorProfileModel({this.creator, this.stats});

  CreatorProfileModel.fromJson(Map<String, dynamic> json) {
    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    if (stats != null) {
      data['stats'] = stats!.toJson();
    }
    return data;
  }
}

class Creator {
  String? sId;
  String? fullName;
  String? username;
  String? email;
  Avatar? avatar;
  int? xp;
  int? level;

  Creator(
      {this.sId,
      this.fullName,
      this.username,
      this.email,
      this.avatar,
      this.xp,
      this.level});

  Creator.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    email = json['email'];
    avatar =
        json['avatar'] != null ? Avatar.fromJson(json['avatar']) : null;
    xp = json['xp'];
    level = json['level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['username'] = username;
    data['email'] = email;
    if (avatar != null) {
      data['avatar'] = avatar!.toJson();
    }
    data['xp'] = xp;
    data['level'] = level;
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

class Stats {
  int? totalCourses;
  int? activeCourses;
  int? totalEnrolledUsers;
  double? averageRating;
  int? totalGroups;
  List<GraphData>? graphData;
  List<RatingsPerCourse>? ratingsPerCourse;

  Stats(
      {this.totalCourses,
      this.activeCourses,
      this.totalEnrolledUsers,
      this.averageRating,
      this.totalGroups,
      this.graphData,
      this.ratingsPerCourse});

  Stats.fromJson(Map<String, dynamic> json) {
    totalCourses = json['totalCourses'];
    activeCourses = json['activeCourses'];
    totalEnrolledUsers = json['totalEnrolledUsers'];
    averageRating = (json['averageRating'] as num?)?.toDouble();
    totalGroups = json['totalGroups'];
    if (json['graphData'] != null) {
      graphData = <GraphData>[];
      json['graphData'].forEach((v) {
        graphData!.add(GraphData.fromJson(v));
      });
    }
    if (json['ratingsPerCourse'] != null) {
      ratingsPerCourse = <RatingsPerCourse>[];
      json['ratingsPerCourse'].forEach((v) {
        ratingsPerCourse!.add(RatingsPerCourse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCourses'] = totalCourses;
    data['activeCourses'] = activeCourses;
    data['totalEnrolledUsers'] = totalEnrolledUsers;
    data['averageRating'] = averageRating;
    data['totalGroups'] = totalGroups;
    if (graphData != null) {
      data['graphData'] = graphData!.map((v) => v.toJson()).toList();
    }
    if (ratingsPerCourse != null) {
      data['ratingsPerCourse'] =
          ratingsPerCourse!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GraphData {
  String? courseId;
  String? courseTitle;
  int? enrolledUsers;

  GraphData({this.courseId, this.courseTitle, this.enrolledUsers});

  GraphData.fromJson(Map<String, dynamic> json) {
    courseId = json['courseId'];
    courseTitle = json['courseTitle'];
    enrolledUsers = json['enrolledUsers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['courseId'] = courseId;
    data['courseTitle'] = courseTitle;
    data['enrolledUsers'] = enrolledUsers;
    return data;
  }
}

class RatingsPerCourse {
  String? courseId;
  String? courseTitle;
  double? averageRating;
  int? totalReviews;

  RatingsPerCourse({
    this.courseId,
    this.courseTitle,
    this.averageRating,
    this.totalReviews,
  });

  RatingsPerCourse.fromJson(Map<String, dynamic> json) {
    courseId = json['courseId'];
    courseTitle = json['courseTitle'];
    averageRating =
        (json['averageRating'] as num?)?.toDouble(); // Safely cast to double
    totalReviews = json['totalReviews'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['courseId'] = courseId;
    data['courseTitle'] = courseTitle;
    data['averageRating'] = averageRating;
    data['totalReviews'] = totalReviews;
    return data;
  }
}
