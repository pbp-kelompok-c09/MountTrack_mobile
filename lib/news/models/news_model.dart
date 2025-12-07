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
  String username;
  int totalLikes;
  bool isLiked;
  List<String>? additionalImages;

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
    this.additionalImages,
  });

  factory NewsEntry.fromJson(Map<String, dynamic> json) => NewsEntry(
    id: json["id"].toString(),
    title: json["title"],
    content: json["content"],
    publishedDate: json["published_date"] != null
        ? DateTime.parse(json["published_date"])
        : DateTime.now(),
    newsViews: json["news_views"] ?? 0,
    pinnedThumbnail: json["pinned_thumbnail"],
    userId: json["user_id"]?.toString(),

    username: json["username"] ?? "Anonymous",

    totalLikes: json["total_likes"] ?? 0,
    isLiked: json["is_liked"] ?? false,
    additionalImages: json["additional_images"] == null
        ? []
        : List<String>.from(json["additional_images"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "published_date": publishedDate.toIso8601String(),
    "news_views": newsViews,
    "pinned_thumbnail": pinnedThumbnail,
    "user_id": userId,
    "username": username,
    "total_likes": totalLikes,
    "is_liked": isLiked,
    "additional_images": additionalImages,
  };
}
