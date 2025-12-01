class GetAllCreatorCoursesModel {
  String? sId;
  String? title;
  String? description;
  String? thumbnail;
  List<Section>? sections;
  int? xpOnStart;
  int? xpOnCompletion;
  int? xpPerPerfectQuiz;
  int? xpOnLessonCompletion;
  CreatedBy? createdBy;
  bool? isPublished;
  int? coins;
  List<String>? tags;
  String? language;
  bool? isPaid;
  String? createdAt;
  String? updatedAt;
  int? iV;
  double? averageRating;
  int? totalReviews;

  GetAllCreatorCoursesModel({
    this.sId,
    this.title,
    this.description,
    this.thumbnail,
    this.sections,
    this.xpOnStart,
    this.xpOnCompletion,
    this.xpPerPerfectQuiz,
    this.xpOnLessonCompletion,
    this.createdBy,
    this.isPublished,
    this.coins,
    this.tags,
    this.language,
    this.isPaid,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.averageRating,
    this.totalReviews,
  });

  GetAllCreatorCoursesModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];

    if (json['sections'] != null) {
      sections = <Section>[];
      json['sections'].forEach((v) {
        sections!.add(Section.fromJson(v));
      });
    }

    xpOnStart = json['xpOnStart'];
    xpOnCompletion = json['xpOnCompletion'];
    xpPerPerfectQuiz = json['xpPerPerfectQuiz'];
    xpOnLessonCompletion = json['xpOnLessonCompletion'];
    createdBy = json['createdBy'] != null
        ? CreatedBy.fromJson(json['createdBy'])
        : null;
    isPublished = json['isPublished'];
    coins = json['coins'];
    tags = json['tags'] != null ? List<String>.from(json['tags']) : null;
    language = json['language'];
    isPaid = json['isPaid'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    averageRating = (json['averageRating'] as num?)?.toDouble();
    totalReviews = json['totalReviews'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['thumbnail'] = thumbnail;
    if (sections != null) {
      data['sections'] = sections!.map((v) => v.toJson()).toList();
    }
    data['xpOnStart'] = xpOnStart;
    data['xpOnCompletion'] = xpOnCompletion;
    data['xpPerPerfectQuiz'] = xpPerPerfectQuiz;
    data['xpOnLessonCompletion'] = xpOnLessonCompletion;
    if (createdBy != null) {
      data['createdBy'] = createdBy!.toJson();
    }
    data['isPublished'] = isPublished;
    data['coins'] = coins;
    data['tags'] = tags;
    data['language'] = language;
    data['isPaid'] = isPaid;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['averageRating'] = averageRating;
    data['totalReviews'] = totalReviews;
    return data;
  }
}

class Section {
  String? sId;
  String? title;
  int? lessonCount;

  Section({this.sId, this.title, this.lessonCount});

  Section.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    lessonCount = json['lessonCount'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['lessonCount'] = lessonCount;
    return data;
  }
}

class CreatedBy {
  String? sId;
  String? fullName;
  String? email;
  String? role;

  CreatedBy({this.sId, this.fullName, this.email, this.role});

  CreatedBy.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['email'] = email;
    data['role'] = role;
    return data;
  }
}
