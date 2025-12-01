class EnrolledCoursesModel {
  List<EnrolledCourses>? enrolledCourses;
  Pagination? pagination;

  EnrolledCoursesModel({this.enrolledCourses, this.pagination});

  EnrolledCoursesModel.fromJson(Map<String, dynamic> json) {
    if (json['enrolledCourses'] != null) {
      enrolledCourses = <EnrolledCourses>[];
      json['enrolledCourses'].forEach((v) {
        enrolledCourses!.add(EnrolledCourses.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (enrolledCourses != null) {
      data['enrolledCourses'] =
          enrolledCourses!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class EnrolledCourses {
  String? id;
  String? title;
  String? description;
  String? thumbnail;
  bool? isPaid;
  int? totalLessons;
  int? completedLessons;
  int? percentageCompleted;
  Group? group;
  Ratings? ratings;
  Creator? creator;
  List<Sections>? sections;

  EnrolledCourses(
      {this.id,
      this.title,
      this.description,
      this.thumbnail,
      this.isPaid,
      this.totalLessons,
      this.completedLessons,
      this.percentageCompleted,
      this.group,
      this.ratings,
      this.creator,
      this.sections});

  EnrolledCourses.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    isPaid = json['isPaid'];
    totalLessons = json['totalLessons'];
    completedLessons = json['completedLessons'];
    percentageCompleted = json['percentageCompleted'];
    group = json['group'] != null ? Group.fromJson(json['group']) : null;
    ratings =
        json['ratings'] != null ? Ratings.fromJson(json['ratings']) : null;
    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections!.add(Sections.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['thumbnail'] = thumbnail;
    data['isPaid'] = isPaid;
    data['totalLessons'] = totalLessons;
    data['completedLessons'] = completedLessons;
    data['percentageCompleted'] = percentageCompleted;
    if (group != null) {
      data['group'] = group!.toJson();
    }
    if (ratings != null) {
      data['ratings'] = ratings!.toJson();
    }
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    if (sections != null) {
      data['sections'] = sections!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Group {
  String? id;
  String? name;
  String? avatar;
  List<String>? admins;
  int? membersCount;

  Group({this.id, this.name, this.avatar, this.admins, this.membersCount});

  Group.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
    admins = json['admins'].cast<String>();
    membersCount = json['membersCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['avatar'] = avatar;
    data['admins'] = admins;
    data['membersCount'] = membersCount;
    return data;
  }
}

class Ratings {
  double? avgRating;
  double? totalReviews; // changed to double

  Ratings({this.avgRating, this.totalReviews});

  Ratings.fromJson(Map<String, dynamic> json) {
    avgRating = (json['avgRating'] as num?)?.toDouble();
    totalReviews = (json['totalReviews'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['avgRating'] = avgRating;
    data['totalReviews'] = totalReviews;
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

class Sections {
  String? id;
  String? title;
  List<Lesson>? lessons;

  Sections({this.id, this.title, this.lessons});

  Sections.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    if (json['lessons'] != null) {
      lessons = <Lesson>[];
      json['lessons'].forEach((v) {
        lessons!.add(Lesson.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['title'] = title;
    if (lessons != null) {
      data['lessons'] = lessons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Lesson {
  String? id;
  String? title;
  String? contentType;
  String? textContent;
  List<Quiz>? quiz;
  bool? isCompleted;
  int? quizScore;
  String? completedAt;
  String? videoUrl;

  Lesson({
    this.id,
    this.title,
    this.contentType,
    this.textContent,
    this.quiz,
    this.isCompleted,
    this.quizScore,
    this.completedAt,
    this.videoUrl,
  });

  Lesson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    contentType = json['contentType'];
    textContent = json['textContent'];
    if (json['quiz'] != null) {
      quiz = <Quiz>[];
      json['quiz'].forEach((v) {
        quiz!.add(Quiz.fromJson(v));
      });
    }
    isCompleted = json['isCompleted'];
    quizScore = json['quizScore'];
    completedAt = json['completedAt'];
    videoUrl = json['videoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['title'] = title;
    data['contentType'] = contentType;
    data['textContent'] = textContent;
    if (quiz != null) {
      data['quiz'] = quiz!.map((v) => v.toJson()).toList();
    }
    data['isCompleted'] = isCompleted;
    data['quizScore'] = quizScore;
    data['completedAt'] = completedAt;
    data['videoUrl'] = videoUrl;
    return data;
  }
}

class Quiz {
  String? question;
  List<String>? options;
  String? correctAnswer;

  Quiz({this.question, this.options, this.correctAnswer});

  Quiz.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    options = json['options'].cast<String>();
    correctAnswer = json['correctAnswer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question'] = question;
    data['options'] = options;
    data['correctAnswer'] = correctAnswer;
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
