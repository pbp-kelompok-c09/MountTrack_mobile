class Mountain {
  final int id;
  final String name;
  final String url;
  final int heightMdpl;
  final String province;
  final String imageUrl;
  final String description;
  final String slug;
  final bool availability;
  final int minBook;
  final String experienceRequired;

  Mountain({
    required this.id,
    required this.name,
    required this.url,
    required this.heightMdpl,
    required this.province,
    required this.imageUrl,
    required this.description,
    required this.slug,
    required this.availability,
    required this.minBook,
    required this.experienceRequired,
  });

  factory Mountain.fromJson(Map<String, dynamic> json) {
    return Mountain(
      id: json['id'] as int,
      name: json['name'] as String,
      url: json['url'] as String? ?? '',
      heightMdpl: json['height_mdpl'] as int,
      province: json['province'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      description: json['description'] as String,
      slug: json['slug'] as String,
      availability: json['availability'] as bool? ?? true,
      minBook: json['min_book'] as int? ?? 1,
      experienceRequired: json['experience_required'] as String? ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'height_mdpl': heightMdpl,
      'province': province,
      'image_url': imageUrl,
      'description': description,
      'slug': slug,
      'availability': availability,
      'min_book': minBook,
      'experience_required': experienceRequired,
    };
  }
}
