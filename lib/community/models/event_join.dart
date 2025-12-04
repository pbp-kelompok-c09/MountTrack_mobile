class EventJoin {
  final int id;
  final int event;
  final int user;
  String status; // PENDING / CONFIRMED / WAITLIST / CANCELLED
  final DateTime joinedAt;

  EventJoin({
    required this.id,
    required this.event,
    required this.user,
    required this.status,
    required this.joinedAt,
  });
}
