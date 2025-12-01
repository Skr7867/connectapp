class TwoFAQrCodeModel {
  String? message;
  String? qrCode;
  String? secretKey;

  TwoFAQrCodeModel({this.message, this.qrCode, this.secretKey});

  TwoFAQrCodeModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    qrCode = json['qrCode'];
    secretKey = json['secretKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['message'] = message;
    data['qrCode'] = qrCode;
    data['secretKey'] = secretKey;
    return data;
  }
}
