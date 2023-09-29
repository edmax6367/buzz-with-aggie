import 'post_content.dart';

class Post {
  String? title;
  String? banner;
  String? description;
  List<Content> content = [];
  List<Comment> comments = [];
  List views = [];
  String? time;
  String key;

  Post(
      {this.banner,
      this.title,
      this.description,
      required this.content,
      required this.key,
      required this.comments,
      required this.views,
      this.time});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'banner': banner,
      'description': description,
      'content': content.map((c) => c.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'views': views.map((c) => c.toJson()).toList(),
      'time': time,
    };
  }
}
