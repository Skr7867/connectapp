class InventoryAvatarModel {
  bool? success;
  Inventory? inventory;

  InventoryAvatarModel({this.success, this.inventory});

  InventoryAvatarModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    inventory = json['inventory'] != null
        ? Inventory.fromJson(json['inventory'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (inventory != null) {
      data['inventory'] = inventory!.toJson();
    }
    return data;
  }
}

class Inventory {
  List<Avatars>? avatars;
  List<Collection>? collection;

  Inventory({this.avatars, this.collection});

  Inventory.fromJson(Map<String, dynamic> json) {
    if (json['avatars'] != null) {
      avatars = <Avatars>[];
      json['avatars'].forEach((v) {
        avatars!.add(Avatars.fromJson(v));
      });
    }
    if (json['collection'] != null) {
      collection = <Collection>[];
      json['collection'].forEach((v) {
        collection!.add(Collection.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (avatars != null) {
      data['avatars'] = avatars!.map((v) => v.toJson()).toList();
    }
    if (collection != null) {
      data['collection'] = collection!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Avatars {
  String? sId;
  String? name;
  String? description;
  String? avatar3dUrl;
  String? avatar2dUrl;
  int? coins;
  String? status;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Avatars(
      {this.sId,
      this.name,
      this.description,
      this.avatar3dUrl,
      this.avatar2dUrl,
      this.coins,
      this.status,
      this.userId,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Avatars.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    avatar3dUrl = json['Avatar3dUrl'];
    avatar2dUrl = json['Avatar2dUrl'];
    coins = json['coins'];
    status = json['status'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['Avatar3dUrl'] = avatar3dUrl;
    data['Avatar2dUrl'] = avatar2dUrl;
    data['coins'] = coins;
    data['status'] = status;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Collection {
  String? sId;
  String? name;
  String? description;
  String? creator;
  List<Avatars>? avatars;
  int? coins;
  bool? isPublished;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Collection(
      {this.sId,
      this.name,
      this.description,
      this.creator,
      this.avatars,
      this.coins,
      this.isPublished,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Collection.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    creator = json['creator'];
    if (json['avatars'] != null) {
      avatars = <Avatars>[];
      json['avatars'].forEach((v) {
        avatars!.add(Avatars.fromJson(v));
      });
    }
    coins = json['coins'];
    isPublished = json['isPublished'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['creator'] = creator;
    if (avatars != null) {
      data['avatars'] = avatars!.map((v) => v.toJson()).toList();
    }
    data['coins'] = coins;
    data['isPublished'] = isPublished;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
