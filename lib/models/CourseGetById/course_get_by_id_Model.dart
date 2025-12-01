// ignore: file_names
class CourseGetByIdModel {
  String? sId;
  String? title;
  String? description;
  String? thumbnail;
  List<Sections>? sections;
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
  double? totalReviews;

  CourseGetByIdModel(
      {this.sId,
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
      this.totalReviews});

  CourseGetByIdModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections!.add(Sections.fromJson(v));
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
    tags = json['tags'].cast<String>();
    language = json['language'];
    isPaid = json['isPaid'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    averageRating = (json['averageRating'] != null)
        ? (json['averageRating'] as num).toDouble()
        : null;

    totalReviews = (json['totalReviews'] != null)
        ? (json['totalReviews'] as num).toDouble()
        : null;
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

class Sections {
  String? sId;
  String? title;
  List<Lessons>? lessons;
  int? iV;

  Sections({this.sId, this.title, this.lessons, this.iV});

  Sections.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    if (json['lessons'] != null) {
      lessons = <Lessons>[];
      json['lessons'].forEach((v) {
        lessons!.add(Lessons.fromJson(v));
      });
    }
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    if (lessons != null) {
      data['lessons'] = lessons!.map((v) => v.toJson()).toList();
    }
    data['__v'] = iV;
    return data;
  }
}

class Lessons {
  String? sId;
  String? title;
  String? description;
  String? contentType;
  String? textContent;
  List<Quiz>? quiz;
  String? updatedAt;
  int? iV;

  Lessons(
      {this.sId,
      this.title,
      this.description,
      this.contentType,
      this.textContent,
      this.quiz,
      this.updatedAt,
      this.iV});

  Lessons.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    contentType = json['contentType'];
    textContent = json['textContent'];
    if (json['quiz'] != null) {
      quiz = <Quiz>[];
      json['quiz'].forEach((v) {
        quiz!.add(Quiz.fromJson(v));
      });
    }
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['contentType'] = contentType;
    data['textContent'] = textContent;
    if (quiz != null) {
      data['quiz'] = quiz!.map((v) => v.toJson()).toList();
    }
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Quiz {
  String? question;
  List<String>? options;
  String? correctAnswer;
  String? sId;

  Quiz({this.question, this.options, this.correctAnswer, this.sId});

  Quiz.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    options = json['options'].cast<String>();
    correctAnswer = json['correctAnswer'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question'] = question;
    data['options'] = options;
    data['correctAnswer'] = correctAnswer;
    data['_id'] = sId;
    return data;
  }
}

class CreatedBy {
  String? sId;
  String? fullName;
  String? email;
  String? id;

  CreatedBy({this.sId, this.fullName, this.email, this.id});

  CreatedBy.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['email'] = email;
    data['id'] = id;
    return data;
  }
}
