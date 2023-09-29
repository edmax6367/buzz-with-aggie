class Content {
  String? type;
  String? data;

  Content({this.type, this.data});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
    };
  }
}

class Comment {
  String content;
  int time;

  Comment({required this.content, required this.time});

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'time': time,
    };
  }
}
