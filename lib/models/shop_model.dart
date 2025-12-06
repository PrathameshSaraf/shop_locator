import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final List<String> types;
  final List<String> photoRefs;
  final String? phoneNumber;
  final bool? openNow;
  final double? rating;
  final int? userRatingsTotal;

  const Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.types,
    required this.photoRefs,
    this.phoneNumber,
    this.openNow,
    this.rating,
    this.userRatingsTotal,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['place_id'] ?? '',
      name: json['name'] ?? 'Unknown Shop',
      address: json['vicinity'] ?? 'No address available',
      lat: json['geometry']['location']['lat']?.toDouble() ?? 0.0,
      lng: json['geometry']['location']['lng']?.toDouble() ?? 0.0,
      types: List<String>.from(json['types'] ?? []),
      photoRefs:
          (json['photos'] as List?)
              ?.map((e) => e['photo_reference'] as String)
              .toList() ??
          [],
      phoneNumber:
          json['formatted_phone_number'], // Usually requires Place Details
      openNow: json['opening_hours']?['open_now'],
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['user_ratings_total'],
    );
  }

  static const empty = Shop(
    id: '',
    name: '',
    address: '',
    lat: 0,
    lng: 0,
    types: [],
    photoRefs: [],
  );

  Shop copyWith({
    String? id,
    String? name,
    String? address,
    double? lat,
    double? lng,
    List<String>? types,
    List<String>? photoRefs,
    String? phoneNumber,
    bool? openNow,
    double? rating,
    int? userRatingsTotal,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      types: types ?? this.types,
      photoRefs: photoRefs ?? this.photoRefs,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      openNow: openNow ?? this.openNow,
      rating: rating ?? this.rating,
      userRatingsTotal: userRatingsTotal ?? this.userRatingsTotal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'types': types,
      'photoRefs': photoRefs,
      'phoneNumber': phoneNumber,
      'openNow': openNow,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
    };
  }

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      lng: map['lng']?.toDouble() ?? 0.0,
      types: List<String>.from(map['types'] ?? []),
      photoRefs: List<String>.from(map['photoRefs'] ?? []),
      phoneNumber: map['phoneNumber'],
      openNow: map['openNow'],
      rating: map['rating']?.toDouble(),
      userRatingsTotal: map['userRatingsTotal'],
    );
  }

  String get category {
    if (types.any(
      (t) => [
        'restaurant',
        'cafe',
        'bakery',
        'food',
        'meal_takeaway',
        'meal_delivery',
      ].contains(t),
    )) {
      return 'food';
    }
    if (types.any(
      (t) => [
        'hospital',
        'pharmacy',
        'doctor',
        'health',
        'dentist',
        'gym',
      ].contains(t),
    )) {
      return 'health';
    }
    if (types.any(
      (t) => [
        'clothing_store',
        'shoe_store',
        'shopping_mall',
        'department_store',
      ].contains(t),
    )) {
      return 'clothing';
    }
    if (types.any((t) => ['electronics_store', 'computer_store'].contains(t))) {
      return 'electronics';
    }
    if (types.any(
      (t) => ['car_repair', 'gas_station', 'car_dealer', 'parking'].contains(t),
    )) {
      return 'automotive';
    }
    if (types.any(
      (t) => [
        'laundry',
        'bank',
        'atm',
        'post_office',
        'hair_care',
        'beauty_salon',
        'lodging',
      ].contains(t),
    )) {
      return 'services';
    }
    return 'store';
  }

  @override
  String toString() {
    return 'Shop(id: $id, name: $name, address: $address, lat: $lat, lng: $lng, types: $types, photoRefs: $photoRefs, phoneNumber: $phoneNumber, openNow: $openNow, rating: $rating, userRatingsTotal: $userRatingsTotal)';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    lat,
    lng,
    types,
    photoRefs,
    phoneNumber,
    openNow,
    rating,
    userRatingsTotal,
  ];
}
