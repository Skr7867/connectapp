class JoinSpaceModel {
  bool? success;
  String? message;
  String? roomUrl;

  JoinSpaceModel({this.success, this.message, this.roomUrl});

  JoinSpaceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    roomUrl = json['roomUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['roomUrl'] = roomUrl;
    return data;
  }
}
