import 'comment.dart';
import 'event_join.dart';

class CommunityEvent {
  final int id;
  final String title;
  final String mountainName;
  final DateTime startAt;
  final DateTime? endAt;
  final int capacity;
  final int? price;
  final String difficulty; // BEGINNER / INTERMEDIATE / ADVANCED
  final String meetingPoint;
  final String contactPerson;
  final String description;
  String status; // DRAFT / OPEN / FULL / CANCELLED
  final int organizer;

  final List<EventJoin> joins;
  final List<Comment> comments;

  CommunityEvent({
    required this.id,
    required this.title,
    required this.mountainName,
    required this.startAt,
    this.endAt,
    required this.capacity,
    this.price,
    required this.difficulty,
    required this.meetingPoint,
    required this.contactPerson,
    required this.description,
    required this.status,
    required this.organizer,
    List<EventJoin>? joins,
    List<Comment>? comments,
  })  : joins = joins ?? <EventJoin>[],
        comments = comments ?? <Comment>[];

  int confirmedCount() => joins.where((j) => j.status == 'CONFIRMED').length;

  bool isFull() => confirmedCount() >= capacity;

  void recalcStatusAfterJoinChange() {
    if (status == 'CANCELLED' || status == 'DRAFT') return;
    status = isFull() ? 'FULL' : 'OPEN';
  }

  factory CommunityEvent.fromJson(Map<String, dynamic> json) {
    return CommunityEvent(
      id: json['id'],
      title: json['title'],
      mountainName: json['mountain_name'],
      startAt: DateTime.parse(json['start_at']),
      endAt: json['end_at'] != null ? DateTime.parse(json['end_at']) : null,
      capacity: json['capacity'],
      price: json['price'],
      difficulty: json['difficulty'],
      meetingPoint: json['meeting_point'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      description: json['description'] ?? '',
      status: json['status'],
      organizer: json['organizer'],
      joins: json['joins'] != null
          ? (json['joins'] as List).map((j) => EventJoin.fromJson(j)).toList()
          : [],
      comments: json['comments'] != null
          ? (json['comments'] as List).map((c) => Comment.fromJson(c)).toList()
          : [],
    );
  }
}
