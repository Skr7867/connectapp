class Lesson {
  String? id;
  String? title;
  String? description;
  String? contentType;
  String? videoUrl;
  bool? isCompleted;

  Lesson({
    this.id,
    this.title,
    this.description,
    this.contentType,
    this.videoUrl,
    this.isCompleted = false,
  });

  Lesson.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    contentType = json['contentType'];
    videoUrl = json['videoUrl'];
    isCompleted = json['isCompleted'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['contentType'] = contentType;
    data['videoUrl'] = videoUrl;
    data['isCompleted'] = isCompleted;
    return data;
  }
}

// Note: Ensure Course and Section classes are unchanged or updated if needed
