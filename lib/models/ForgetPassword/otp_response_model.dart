class OtpResponse {
  final String message;
  final String? otp; // Optional OTP field

  OtpResponse({required this.message, this.otp});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'] as String,
      otp: json['otp'] as String?, // Handle null if otp is not present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (otp != null) 'otp': otp,
    };
  }
}
