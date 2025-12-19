class PendingFollowRequestModel {
  String? message;
  List<Requests>? requests;

  PendingFollowRequestModel({this.message, this.requests});

  PendingFollowRequestModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['requests'] != null) {
      requests = <Requests>[];
      json['requests'].forEach((v) {
        requests!.add(new Requests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.requests != null) {
      data['requests'] = this.requests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Requests {
  String? sId;
  From? from;
  String? to;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Requests(
      {this.sId,
      this.from,
      this.to,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Requests.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    from = json['from'] != null ? new From.fromJson(json['from']) : null;
    to = json['to'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.from != null) {
      data['from'] = this.from!.toJson();
    }
    data['to'] = this.to;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class From {
  String? sId;
  String? fullName;
  String? username;
  Avatar? avatar;
  String? id;

  From({this.sId, this.fullName, this.username, this.avatar, this.id});

  From.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    username = json['username'];
    avatar =
        json['avatar'] != null ? new Avatar.fromJson(json['avatar']) : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['username'] = this.username;
    if (this.avatar != null) {
      data['avatar'] = this.avatar!.toJson();
    }
    data['id'] = this.id;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
