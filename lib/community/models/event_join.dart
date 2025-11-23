class EventJoin {
  final int id;
  final int event;
  final int user;
  final String status;
  final DateTime joinedAt;

  EventJoin({
    required this.id,
    required this.event,
    required this.user,
    required this.status,
    required this.joinedAt,
  });

  factory EventJoin.fromJson(Map<String, dynamic> json) {
    return EventJoin(
      id: json['id'],
      event: json['event'],
      user: json['user'],
      status: json['status'],
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }
}
