// To parse this JSON data, do
//
//     final newsEntry = newsEntryFromJson(jsonString);

import 'dart:convert';

List<NewsEntry> newsEntryFromJson(String str) =>
    List<NewsEntry>.from(json.decode(str).map((x) => NewsEntry.fromJson(x)));

String newsEntryToJson(List<NewsEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewsEntry {
  String id;
  String title;
  String content;
  DateTime publishedDate;
  int newsViews;
  String? pinnedThumbnail;
  String? userId;
  Username username;
  int totalLikes;
  bool isLiked;

  NewsEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedDate,
    required this.newsViews,
    required this.pinnedThumbnail,
    required this.userId,
    required this.username,
    required this.totalLikes,
    required this.isLiked,
  });

  factory NewsEntry.fromJson(Map<String, dynamic> json) => NewsEntry(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    publishedDate: DateTime.parse(json["published_date"]),
    newsViews: json["news_views"],
    pinnedThumbnail: json["pinned_thumbnail"],
    userId: json["user_id"],
    username: usernameValues.map[json["username"]]!,
    totalLikes: json["total_likes"],
    isLiked: json["is_liked"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "published_date": publishedDate.toIso8601String(),
    "news_views": newsViews,
    "pinned_thumbnail": pinnedThumbnail,
    "user_id": userId,
    "username": usernameValues.reverse[username],
    "total_likes": totalLikes,
  };
}

enum Username { ANONYMOUS, USER1 }

final usernameValues = EnumValues({
  "Anonymous": Username.ANONYMOUS,
  "user1": Username.USER1,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
