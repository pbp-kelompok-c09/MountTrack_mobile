class Comment {
  final int id;
  final int user;
  final int event;
  final String body;
  final DateTime createdAt;
  final String? username;

  Comment({
    required this.id,
    required this.user,
    required this.event,
    required this.body,
    required this.createdAt,
    this.username,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      user: json['user'],
      event: json['event'],
      body: json['body'],
      createdAt: DateTime.parse(json['created_at']),
      username: json['username'],
    );
  }
}
