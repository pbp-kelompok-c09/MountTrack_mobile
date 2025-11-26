import 'booking_member.dart';

class Booking {
  final int id;
  final String gunungNama;
  final int pax;
  final List<String> levels;
  final bool porterRequired;
  final String createdAt;
  final List<BookingMember> members;

  Booking({
    required this.id,
    required this.gunungNama,
    required this.pax,
    required this.levels,
    required this.porterRequired,
    required this.createdAt,
    required this.members,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['booking_id'],
      gunungNama: json['gunung_nama'],
      pax: json['pax'],
      levels: List<String>.from(json['levels']),
      porterRequired: json['porter_required'],
      createdAt: json['created_at'],
      members: (json['anggota'] as List)
          .map((m) => BookingMember.fromJson(m))
          .toList(),
    );
  }
}
