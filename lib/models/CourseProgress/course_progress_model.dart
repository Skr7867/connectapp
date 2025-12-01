class CourseProgressModel {
  Progress? progress;
  int? totalLessons;
  int? lessonsCompleted;
  int? percentageCompleted;

  CourseProgressModel(
      {this.progress,
      this.totalLessons,
      this.lessonsCompleted,
      this.percentageCompleted});

  CourseProgressModel.fromJson(Map<String, dynamic> json) {
    progress = json['progress'] != null
        ? Progress.fromJson(json['progress'])
        : null;
    totalLessons = json['totalLessons'];
    lessonsCompleted = json['lessonsCompleted'];
    percentageCompleted = json['percentageCompleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (progress != null) {
      data['progress'] = progress!.toJson();
    }
    data['totalLessons'] = totalLessons;
    data['lessonsCompleted'] = lessonsCompleted;
    data['percentageCompleted'] = percentageCompleted;
    return data;
  }
}

class Progress {
  String? sId;
  String? userId;
  String? courseId;
  List<CompletedLessons>? completedLessons;
  String? startedAt;
  int? xpEarned;
  bool? isCompleted;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? completedAt;

  Progress(
      {this.sId,
      this.userId,
      this.courseId,
      this.completedLessons,
      this.startedAt,
      this.xpEarned,
      this.isCompleted,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.completedAt});

  Progress.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    courseId = json['courseId'];
    if (json['completedLessons'] != null) {
      completedLessons = <CompletedLessons>[];
      json['completedLessons'].forEach((v) {
        completedLessons!.add(CompletedLessons.fromJson(v));
      });
    }
    startedAt = json['startedAt'];
    xpEarned = json['xpEarned'];
    isCompleted = json['isCompleted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    completedAt = json['completedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['courseId'] = courseId;
    if (completedLessons != null) {
      data['completedLessons'] =
          completedLessons!.map((v) => v.toJson()).toList();
    }
    data['startedAt'] = startedAt;
    data['xpEarned'] = xpEarned;
    data['isCompleted'] = isCompleted;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['completedAt'] = completedAt;
    return data;
  }
}

class CompletedLessons {
  String? lessonId;
  bool? isCompleted;
  int? quizScore;
  String? completedAt;
  String? sId;

  CompletedLessons(
      {this.lessonId,
      this.isCompleted,
      this.quizScore,
      this.completedAt,
      this.sId});

  CompletedLessons.fromJson(Map<String, dynamic> json) {
    lessonId = json['lessonId'];
    isCompleted = json['isCompleted'];
    quizScore = json['quizScore'];
    completedAt = json['completedAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lessonId'] = lessonId;
    data['isCompleted'] = isCompleted;
    data['quizScore'] = quizScore;
    data['completedAt'] = completedAt;
    data['_id'] = sId;
    return data;
  }
}
