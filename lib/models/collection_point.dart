import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class CollectionPoint {
  final String id;
  final String name;
  final String description;
  final String address;
  final String ownerName;
  final int rating;
  final LatLng location;
  final String imageUrl;
  final List<String> materialTypes;

  CollectionPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.ownerName,
    required this.rating,
    required this.location,
    required this.imageUrl,
    required this.materialTypes,
  });

  factory CollectionPoint.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return CollectionPoint(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      address: data['address'],
      ownerName: data['ownerName'],
      rating: data['rating'],
      location:
          LatLng(data['location']['latitude'], data['location']['longitude']),
      imageUrl: data['imageUrl'],
      materialTypes: List<String>.from(data['materialTypes']),
    );
  }
}
