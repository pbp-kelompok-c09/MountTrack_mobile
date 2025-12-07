
class BookingUserProfile {
  final String id;
  final String username;
  final String nama;
  final int? umur;
  final String? noTelepon;
  final String? email;
  final String categoryExperience;
  final String? jenisKelamin;

  BookingUserProfile({
    required this.id,
    required this.username,
    required this.nama,
    this.umur,
    this.noTelepon,
    this.email,
    required this.categoryExperience,
    this.jenisKelamin,
  });

  factory BookingUserProfile.fromJson(Map<String, dynamic> json) {
    return BookingUserProfile(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      umur: json['umur'] != null ? int.tryParse(json['umur'].toString()) : null,
      noTelepon: json['nomor_telepon']?.toString(),
      email: json['email']?.toString(),
      categoryExperience: json['category_experience']?.toString() ?? 'beginner',
      jenisKelamin: json['jenis_kelamin']?.toString(),
    );
  }

  @override
  String toString() => nama;
}
