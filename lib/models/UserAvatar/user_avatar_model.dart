class UserAvatarModel {
  String? message;
  CurrentAvatar? currentAvatar;
  List<PurchasedAvatars>? purchasedAvatars;

  UserAvatarModel({this.message, this.currentAvatar, this.purchasedAvatars});

  UserAvatarModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    currentAvatar = json['currentAvatar'] != null
        ? CurrentAvatar.fromJson(json['currentAvatar'])
        : null;
    if (json['purchasedAvatars'] != null) {
      purchasedAvatars = <PurchasedAvatars>[];
      json['purchasedAvatars'].forEach((v) {
        purchasedAvatars!.add(PurchasedAvatars.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (currentAvatar != null) {
      data['currentAvatar'] = currentAvatar!.toJson();
    }
    if (purchasedAvatars != null) {
      data['purchasedAvatars'] =
          purchasedAvatars!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CurrentAvatar {
  String? sId;
  String? name;
  String? imageUrl;

  CurrentAvatar({this.sId, this.name, this.imageUrl});

  CurrentAvatar.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['imageUrl'] = imageUrl;
    return data;
  }
}

class PurchasedAvatars {
  String? sId;
  String? name;
  String? imageUrl;
  int? coins;

  PurchasedAvatars({this.sId, this.name, this.imageUrl, this.coins});

  PurchasedAvatars.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    coins = json['coins'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['imageUrl'] = imageUrl;
    data['coins'] = coins;
    return data;
  }
}
