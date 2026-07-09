class Cinema {
  final String id;
  final String name;
  final String logoUrl;
  final String address;
  final String city;
  final double rating;
  final String operatingHours;

  Cinema({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.address,
    required this.city,
    required this.rating,
    required this.operatingHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'address': address,
      'city': city,
      'rating': rating,
      'operatingHours': operatingHours,
    };
  }

  factory Cinema.fromMap(Map<String, dynamic> map) {
    return Cinema(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      operatingHours: map['operatingHours'] ?? '',
    );
  }
}