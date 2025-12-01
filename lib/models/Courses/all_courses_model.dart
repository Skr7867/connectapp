class Creator {
  final String id;
  final String fullName;
  final String email;

  Creator({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
    };
  }
}

class QuizQuestion {
  final String? id;
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['_id'] as String?,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctAnswer: json['correctAnswer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}

class Lesson {
  final String id;
  final String title;
  final String? description;
  final String contentType;
  final String? videoUrl;
  final String? textContent;
  final List<QuizQuestion>? quiz;
  final String updatedAt;
  final int v;
  final bool isCompleted; // Added field

  Lesson({
    required this.id,
    required this.title,
    this.description,
    required this.contentType,
    this.videoUrl,
    this.textContent,
    this.quiz,
    required this.updatedAt,
    required this.v,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      contentType: json['contentType'] as String,
      videoUrl: json['videoUrl'] as String?,
      textContent: json['textContent'] as String?,
      quiz: json['quiz'] != null
          ? (json['quiz'] as List<dynamic>)
              .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList()
          : null,
      updatedAt: json['updatedAt'] as String,
      v: json['__v'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      if (description != null) 'description': description,
      'contentType': contentType,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (textContent != null) 'textContent': textContent,
      if (quiz != null) 'quiz': quiz!.map((q) => q.toJson()).toList(),
      'updatedAt': updatedAt,
      '__v': v,
      'isCompleted': isCompleted,
    };
  }
}

class Section {
  final String id;
  final String title;
  final List<Lesson> lessons;
  final int v;

  Section({
    required this.id,
    required this.title,
    required this.lessons,
    required this.v,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['_id'] as String,
      title: json['title'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
          .toList(),
      v: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'lessons': lessons.map((l) => l.toJson()).toList(),
      '__v': v,
    };
  }
}

class Course {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final List<Section> sections;
  final int xpOnStart;
  final int xpOnCompletion;
  final int xpPerPerfectQuiz;
  final int xpOnLessonCompletion;
  final Creator createdBy;
  final bool isPublished;
  final List<String> tags;
  final String language;
  final bool isPaid;
  final String createdAt;
  final String updatedAt;
  final int v;
  final int totalReviews;
  final double averageRating;
  final int? coins;

  Course({
    this.coins,
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.sections,
    required this.xpOnStart,
    required this.xpOnCompletion,
    required this.xpPerPerfectQuiz,
    required this.xpOnLessonCompletion,
    required this.createdBy,
    required this.isPublished,
    required this.tags,
    required this.language,
    required this.isPaid,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.totalReviews,
    required this.averageRating,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      coins: json['coins'] as int?,
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((s) => Section.fromJson(s as Map<String, dynamic>))
          .toList(),
      xpOnStart: json['xpOnStart'] as int,
      xpOnCompletion: json['xpOnCompletion'] as int,
      xpPerPerfectQuiz: json['xpPerPerfectQuiz'] as int,
      xpOnLessonCompletion: json['xpOnLessonCompletion'] as int,
      createdBy: Creator.fromJson(json['createdBy'] as Map<String, dynamic>),
      isPublished: json['isPublished'] as bool,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      language: json['language'] as String,
      isPaid: json['isPaid'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      v: json['__v'] as int,
      totalReviews: json['totalReviews'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'sections': sections.map((s) => s.toJson()).toList(),
      'xpOnStart': xpOnStart,
      'xpOnCompletion': xpOnCompletion,
      'xpPerPerfectQuiz': xpPerPerfectQuiz,
      'xpOnLessonCompletion': xpOnLessonCompletion,
      'createdBy': createdBy.toJson(),
      'isPublished': isPublished,
      'tags': tags,
      'language': language,
      'isPaid': isPaid,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'totalReviews': totalReviews,
      'averageRating': averageRating,
      if (coins != null) '_coins': coins,
    };
  }
}
