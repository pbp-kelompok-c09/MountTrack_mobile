class BookingMember {
  final String name;
  final int? age;
  final String? gender; 
  final String level; 
  final String? profileId;

  BookingMember({
    required this.name,
    this.age,
    this.gender,
    required this.level,
    this.profileId,
  });

  factory BookingMember.fromJson(Map<String, dynamic> json) {
    return BookingMember(
      name: json['name']?.toString() ?? '',
      age: json['age'] != null ? (json['age'] is int ? json['age'] as int : int.tryParse(json['age'].toString())) : null,
      gender: json['gender']?.toString(),
      level: json['level']?.toString() ?? 'beginner',
      profileId: json['profile_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    if (profileId != null && profileId!.isNotEmpty) {
      return {'profile_id': profileId};
    }
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'level': level,
    };
  }
}