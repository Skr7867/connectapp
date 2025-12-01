class PurchaseSubscriptionResponse {
  bool? success;
  String? message;

  PurchaseSubscriptionResponse({
    this.success,
    this.message,
  });

  PurchaseSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    message = json['message'] as String?;
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
