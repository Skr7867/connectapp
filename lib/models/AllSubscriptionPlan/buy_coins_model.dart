class BuyCoinsModel {
  List<Packages>? packages;

  BuyCoinsModel({this.packages});

  BuyCoinsModel.fromJson(Map<String, dynamic> json) {
    if (json['packages'] != null) {
      packages = <Packages>[];
      json['packages'].forEach((v) {
        packages!.add(Packages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (packages != null) {
      data['packages'] = packages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Packages {
  String? sId;
  String? title;
  int? coins;
  double? price;
  bool? isActive;
  String? description;
  String? createdAt;
  int? iV;

  Packages(
      {this.sId,
      this.title,
      this.coins,
      this.price,
      this.isActive,
      this.description,
      this.createdAt,
      this.iV});

  Packages.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    coins = json['coins'];
    // price = json['price'];
    price = (json['price'] != null)
        ? (json['price'] is num ? json['price'].toDouble() : null)
        : null;
    isActive = json['isActive'];
    description = json['description'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['coins'] = coins;
    data['price'] = price;
    data['isActive'] = isActive;
    data['description'] = description;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}
