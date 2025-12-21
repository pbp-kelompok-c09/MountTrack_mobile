class EventJoin {
  final int id;
  final int event;
  final int user;
  String status; // PENDING / CONFIRMED / WAITLIST / CANCELLED
  final DateTime joinedAt;
  final String? username;

  EventJoin({
    required this.id,
    required this.event,
    required this.user,
    required this.status,
    required this.joinedAt,
    this.username,
  });

  factory EventJoin.fromJson(Map<String, dynamic> json) {
    return EventJoin(
      id: json['id'],
      event: json['event'],
      user: json['user'],
      status: json['status'],
      joinedAt: DateTime.parse(json['joined_at']),
      username: json['username'],
    );
  }
}
