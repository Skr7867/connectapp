class UserCoinsTransactionModel {
  List<Transactions>? transactions;
  int? total;
  int? page;
  int? limit;

  UserCoinsTransactionModel(
      {this.transactions, this.total, this.page, this.limit});

  UserCoinsTransactionModel.fromJson(Map<String, dynamic> json) {
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
  String? sId;
  String? userId;
  String? type;
  int? amount;
  int? balanceAfter;
  String? description;
  String? timestamp;
  int? iV;

  Transactions(
      {this.sId,
      this.userId,
      this.type,
      this.amount,
      this.balanceAfter,
      this.description,
      this.timestamp,
      this.iV});

  Transactions.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    type = json['type'];
    amount = json['amount'];
    balanceAfter = json['balanceAfter'];
    description = json['description'];
    timestamp = json['timestamp'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['type'] = type;
    data['amount'] = amount;
    data['balanceAfter'] = balanceAfter;
    data['description'] = description;
    data['timestamp'] = timestamp;
    data['__v'] = iV;
    return data;
  }
}
