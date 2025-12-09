import 'booking_member.dart';

class Booking {
  final int id;
  final String? gunungNama;
  final int pax;
  final List<String> levels;
  final bool porterRequired;
  final String createdAt;
  final List<BookingMember> members;
  final String? climbingDate; 

  Booking({
    required this.id,
    this.gunungNama,
    required this.pax,
    required this.levels,
    required this.porterRequired,
    required this.createdAt,
    required this.members,
    this.climbingDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v, {int fallback = 0}) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      }
      return false;
    }

    final levelsRaw = json['levels'];
    final List<String> levelsList = [];
    if (levelsRaw is List) {
      for (final e in levelsRaw) {
        levelsList.add(e?.toString() ?? '');
      }
    }

    final idVal = parseInt(json['booking_id'] ?? json['id'], fallback: 0);

    return Booking(
      id: idVal,
      gunungNama: json['gunung_nama']?.toString(),
      pax: parseInt(json['pax'], fallback: 1),
      levels: levelsList,
      porterRequired: parseBool(json['porter_required']),
      createdAt: json['created_at']?.toString() ?? '',
      climbingDate: json['climbing_date']?.toString(),
      members: (json['anggota'] as List? ?? []).map((m) => BookingMember.fromJson(m as Map<String, dynamic>)).toList(),
    );
  }

  DateTime? get createdAtDt {
    try {
      return createdAt.isNotEmpty ? DateTime.parse(createdAt) : null;
    } catch (e) {
      return null;
    }
  }

  get imageUrl => null;

  // helper to build create/update payload expected by Django API
  Map<String, dynamic> toCreatePayload({
    int? gunungId,
    String porterHire = 'no',
    String? climbingDateIso,
  }) {
    return {
      if (gunungId != null) 'gunung_id': gunungId,
      // do not send 'pax' - backend will compute based on anggota + user
      'anggota': members.map((m) => m.toJson()).toList(),
      'porter_hire': porterHire,
      if (climbingDateIso != null) 'climbing_date': climbingDateIso,
    };
  }

   Map<String, dynamic> toCreatePayloadWithPax({
    int? gunungId,
    String porterHire = 'no',
    String? climbingDateIso,
    bool membersAreAdditional = true,
  }) {
    // if members represent additional members, pax = 1 (user) + members.length
    final paxToSend = membersAreAdditional ? (1 + members.length) : members.length;
    return {
      if (gunungId != null) 'gunung_id': gunungId,
      'pax': paxToSend,
      'anggota': members.map((m) => m.toJson()).toList(),
      'porter_hire': porterHire,
      if (climbingDateIso != null) 'climbing_date': climbingDateIso,
    };
  }
}