class BookingMember {
  final String name;
  final int age;
  final String gender;
  final String level;

  BookingMember({
    required this.name,
    required this.age,
    required this.gender,
    required this.level,
  });

  factory BookingMember.fromJson(Map<String, dynamic> json) {
    return BookingMember(
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      level: json['level'],
    );
  }
}
