class Business {
  final String id;
  final String businessName;
  final String categoryName;
  final String? address;
  final String phoneNumber;
  final double rating;
  final double latitude;
  final double longitude;
  final String coverUrl;
  final bool isPremium;
  final String? instagramHandle;
  final String? website;
  final String? description;

  Business({
    required this.id,
    required this.businessName,
    required this.categoryName,
    this.address,
    required this.phoneNumber,
    this.rating = 5.0,
    this.latitude = -1.2974,
    this.longitude = -47.9274,
    required this.coverUrl,
    this.isPremium = false,
    this.instagramHandle,
    this.website,
    this.description,
  });

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      // O campo 'id' nas views/tabelas do Supabase é UUID (String)
      id: map['id'] is String ? map['id'] as String : (map['id'] as int).toString(),
      businessName: map['name'] as String? ?? (map['business_name'] as String? ?? ''),
      categoryName: map['category_name'] as String? ?? '',
      address: map['address'] as String?,
      phoneNumber: map['whatsapp_number'] as String? ?? (map['phone_number'] as String? ?? ''),
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      latitude: (map['latitude'] as num?)?.toDouble() ?? -1.2974,
      longitude: (map['longitude'] as num?)?.toDouble() ?? -47.9274,
      coverUrl: map['image_url'] as String? ?? (map['cover_url'] as String? ?? ''),
      isPremium: map['is_premium'] as bool? ?? false,
      instagramHandle: map['instagram_url'] as String? ?? (map['instagram_handle'] as String?),
      website: map['website'] as String?,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': businessName,
      'category_name': categoryName,
      'address': address,
      'whatsapp_number': phoneNumber,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': coverUrl,
      'is_premium': isPremium,
      'instagram_url': instagramHandle,
      'website': website,
      'description': description,
    };
  }

  Business copyWith({
    String? id,
    String? businessName,
    String? categoryName,
    String? address,
    String? phoneNumber,
    double? rating,
    double? latitude,
    double? longitude,
    String? coverUrl,
    bool? isPremium,
    String? instagramHandle,
    String? website,
    String? description,
  }) {
    return Business(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      categoryName: categoryName ?? this.categoryName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rating: rating ?? this.rating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      coverUrl: coverUrl ?? this.coverUrl,
      isPremium: isPremium ?? this.isPremium,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      website: website ?? this.website,
      description: description ?? this.description,
    );
  }
}
