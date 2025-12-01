class TwofaLoginResponseModel {
  String? message;
  String? tempToken;
  String? method;

  TwofaLoginResponseModel({this.message, this.tempToken, this.method});

  TwofaLoginResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    tempToken = json['tempToken'];
    method = json['method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['tempToken'] = tempToken;
    data['method'] = method;
    return data;
  }
}
