// ignore_for_file: prefer_collection_literals

class AllAvatarModel {
  List<Avatars>? avatars;

  AllAvatarModel({this.avatars});

  AllAvatarModel.fromJson(Map<String, dynamic> json) {
    if (json['avatars'] != null) {
      avatars = <Avatars>[];
      json['avatars'].forEach((v) {
        avatars!.add(Avatars.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (avatars != null) {
      data['avatars'] = avatars!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Avatars {
  String? sId;
  String? name;
  String? imageUrl;
  bool? isActive;
  int? coins;
  int? iV;

  Avatars(
      {this.sId, this.name, this.imageUrl, this.isActive, this.coins, this.iV});

  Avatars.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    imageUrl = json['imageUrl'];
    isActive = json['isActive'];
    coins = json['coins'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    data['imageUrl'] = imageUrl;
    data['isActive'] = isActive;
    data['coins'] = coins;
    data['__v'] = iV;
    return data;
  }
}
