class ClipRepostByUser {
  String? message;
  List<Clips>? clips;

  ClipRepostByUser({this.message, this.clips});

  ClipRepostByUser.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['clips'] != null) {
      clips = <Clips>[];
      json['clips'].forEach((v) {
        clips!.add(Clips.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (clips != null) {
      data['clips'] = clips!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Clips {
  String? sId;
  String? caption;
  List<String>? tags;
  String? processedUrl;
  String? thumbnailUrl;

  Clips(
      {this.sId,
      this.caption,
      this.tags,
      this.processedUrl,
      this.thumbnailUrl});

  Clips.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    caption = json['caption'];
    tags = json['tags'].cast<String>();
    processedUrl = json['processedUrl'];
    thumbnailUrl = json['thumbnailUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['caption'] = caption;
    data['tags'] = tags;
    data['processedUrl'] = processedUrl;
    data['thumbnailUrl'] = thumbnailUrl;
    return data;
  }
}
