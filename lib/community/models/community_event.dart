import 'package:mounttrack_mobile/community/models/comment.dart';
import 'package:mounttrack_mobile/community/models/event_join.dart';

class CommunityEvent {
  final int id;
  final String title;
  final String mountainName;
  final DateTime startAt;
  final DateTime? endAt;
  final int capacity;
  final int? price;
  final String difficulty;
  final String meetingPoint;
  final String contactPerson;
  final String description;
  final String status;
  final int organizer;  // user id

  // Optional: lists
  List<EventJoin>? joins;
  List<Comment>? comments;

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
    this.joins,
    this.comments,
  });

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
      meetingPoint: json['meeting_point'],
      contactPerson: json['contact_person'],
      description: json['description'],
      status: json['status'],
      organizer: json['organizer'],
      joins: json['joins'] != null
          ? (json['joins'] as List).map((e) => EventJoin.fromJson(e)).toList()
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((e) => Comment.fromJson(e)).toList()
          : null,
    );
  }
}
