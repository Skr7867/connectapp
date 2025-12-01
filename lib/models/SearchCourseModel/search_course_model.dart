class SearchCourseModel {
  bool? success;
  List<Data>? data;

  SearchCourseModel({this.success, this.data});

  SearchCourseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? title;
  String? description;
  String? thumbnail;
  List<String>? tags;
  bool? isPaid;
  int? coins;
  Creator? creator;
  List<Sections>? sections;
  Ratings? ratings;
  bool? isEnrolled;

  Data(
      {this.id,
      this.title,
      this.description,
      this.thumbnail,
      this.tags,
      this.isPaid,
      this.coins,
      this.creator,
      this.sections,
      this.ratings,
      this.isEnrolled});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    tags = json['tags'].cast<String>();
    isPaid = json['isPaid'];
    coins = json['coins'];
    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;
    if (json['sections'] != null) {
      sections = <Sections>[];
      json['sections'].forEach((v) {
        sections!.add(Sections.fromJson(v));
      });
    }
    ratings =
        json['ratings'] != null ? Ratings.fromJson(json['ratings']) : null;
    isEnrolled = json['isEnrolled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['thumbnail'] = thumbnail;
    data['tags'] = tags;
    data['isPaid'] = isPaid;
    data['coins'] = coins;
    if (creator != null) {
      data['creator'] = creator!.toJson();
    }
    if (sections != null) {
      data['sections'] = sections!.map((v) => v.toJson()).toList();
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

class Sections {
  String? sId;
  String? title;
  List<Lessons>? lessons;

  Sections({this.sId, this.title, this.lessons});

  Sections.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    if (json['lessons'] != null) {
      lessons = <Lessons>[];
      json['lessons'].forEach((v) {
        lessons!.add(Lessons.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    if (lessons != null) {
      data['lessons'] = lessons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Lessons {
  String? sId;
  String? title;
  String? description;
  String? contentType;
  List<Quiz>? quiz;
  String? updatedAt;
  int? iV;
  String? textContent;
  String? videoUrl;

  Lessons(
      {this.sId,
      this.title,
      this.description,
      this.contentType,
      this.quiz,
      this.updatedAt,
      this.iV,
      this.textContent,
      this.videoUrl});

  Lessons.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    contentType = json['contentType'];
    if (json['quiz'] != null) {
      quiz = <Quiz>[];
      json['quiz'].forEach((v) {
        quiz!.add(Quiz.fromJson(v));
      });
    }
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    textContent = json['textContent'];
    videoUrl = json['videoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['contentType'] = contentType;
    if (quiz != null) {
      data['quiz'] = quiz!.map((v) => v.toJson()).toList();
    }
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['textContent'] = textContent;
    data['videoUrl'] = videoUrl;
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

class Ratings {
  double? avgRating;
  int? totalReviews;

  Ratings({this.avgRating, this.totalReviews});

  Ratings.fromJson(Map<String, dynamic> json) {
    final avg = json['avgRating'];
    if (avg is int) {
      avgRating = avg.toDouble();
    } else if (avg is double) {
      avgRating = avg;
    } else if (avg is String) {
      avgRating = double.tryParse(avg);
    } else {
      avgRating = null;
    }

    // totalReviews can safely stay int
    totalReviews = json['totalReviews'] is double
        ? (json['totalReviews'] as double).toInt()
        : json['totalReviews'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avgRating'] = avgRating;
    data['totalReviews'] = totalReviews;
    return data;
  }
}
