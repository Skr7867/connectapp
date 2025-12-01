class UserTransactionModel {
  List<Transactions>? transactions;
  int? total;
  int? page;
  int? limit;

  UserTransactionModel({this.transactions, this.total, this.page, this.limit});

  UserTransactionModel.fromJson(Map<String, dynamic> json) {
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(Transactions.fromJson(v));
      });
    }
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    return data;
  }
}

class Transactions {
  Meta? meta;
  String? sId;
  String? userId;
  String? role;
  String? type;
  int? coins;
  String? method;
  String? source;
  String? status;
  String? createdAt;
  int? iV;

  Transactions(
      {this.meta,
      this.sId,
      this.userId,
      this.role,
      this.type,
      this.coins,
      this.method,
      this.source,
      this.status,
      this.createdAt,
      this.iV});

  Transactions.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    sId = json['_id'];
    userId = json['userId'];
    role = json['role'];
    type = json['type'];
    coins = json['coins'];
    method = json['method'];
    source = json['source'];
    status = json['status'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    data['_id'] = sId;
    data['userId'] = userId;
    data['role'] = role;
    data['type'] = type;
    data['coins'] = coins;
    data['method'] = method;
    data['source'] = source;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}

class Meta {
  String? referenceId;
  String? description;

  Meta({this.referenceId, this.description});

  Meta.fromJson(Map<String, dynamic> json) {
    referenceId = json['referenceId'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['referenceId'] = referenceId;
    data['description'] = description;
    return data;
  }
}
