class Comment {
  final int id;
  final int user;
  final int event;
  final String body;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.user,
    required this.event,
    required this.body,
    required this.createdAt,
  });
}
