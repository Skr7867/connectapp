class ReferralsNetworkModel {
  bool? success;
  String? userId;
  List<ReferralNode> hierarchy;

  ReferralsNetworkModel({
    this.success,
    this.userId,
    this.hierarchy = const [],
  });

  factory ReferralsNetworkModel.fromJson(Map<String, dynamic> json) {
    return ReferralsNetworkModel(
      success: json['success'] as bool?,
      userId: json['userId'] as String?,
      hierarchy: (json['hierarchy'] as List? ?? [])
          .map((v) => ReferralNode.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'userId': userId,
      'hierarchy': hierarchy.map((v) => v.toJson()).toList(),
    };
  }
}

class ReferralNode {
  final String? id;
  final String? fullName;
  final String? username;
  final String? email;
  final Avatar? avatar;
  final Referrals? referrals;
  final List<ReferralNode> downline;

  ReferralNode({
    this.id,
    this.fullName,
    this.username,
    this.email,
    this.avatar,
    this.referrals,
    this.downline = const [],
  });

  factory ReferralNode.fromJson(Map<String, dynamic> json) {
    return ReferralNode(
      id: json['_id'] as String?,
      fullName: json['fullName'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      avatar: json['avatar'] != null
          ? Avatar.fromJson(json['avatar'] as Map<String, dynamic>)
          : null,
      referrals: json['referrals'] != null
          ? Referrals.fromJson(json['referrals'] as Map<String, dynamic>)
          : null,
      downline: (json['downline'] as List? ?? [])
          .map((v) => ReferralNode.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      if (avatar != null) 'avatar': avatar!.toJson(),
      if (referrals != null) 'referrals': referrals!.toJson(),
      'downline': downline.map((v) => v.toJson()).toList(),
    };
  }
}

class Avatar {
  String? id;
  String? imageUrl;

  Avatar({this.id, this.imageUrl});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['_id'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'imageUrl': imageUrl,
      };
}

class Referrals {
  String? referralCode;

  Referrals({this.referralCode});

  factory Referrals.fromJson(Map<String, dynamic> json) {
    return Referrals(referralCode: json['referralCode'] as String?);
  }

  Map<String, dynamic> toJson() => {'referralCode': referralCode};
}
