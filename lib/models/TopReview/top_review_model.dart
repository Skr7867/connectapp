class TopReviewModel {
  bool? success;
  List<Data>? data;

  TopReviewModel({this.success, this.data});

  TopReviewModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }
}

class Data {
  Course? course;
  User? user;
  int? rating;
  String? comment;
  String? createdAt;
  String? id;

  Data(
      {this.course,
      this.user,
      this.rating,
      this.comment,
      this.createdAt,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    course = json['course'] != null ? Course.fromJson(json['course']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    rating = json['rating'];
    comment = json['comment'] ?? ""; // handle null comments
    createdAt = json['createdAt'] ?? "";
    id = json['id'];
  }
}

class Course {
  String? id;
  String? title;
  String? thumbnail;

  Course({this.id, this.title, this.thumbnail});

  Course.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    thumbnail = json['thumbnail'];
  }
}

class User {
  String? id;
  String? name;
  String? email;
  String? avatar;

  User({this.id, this.name, this.email, this.avatar});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    avatar = json['avatar'] ?? ""; // handle null avatar
  }
}
