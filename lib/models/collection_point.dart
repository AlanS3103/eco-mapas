import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class CollectionPoint {
  String id;
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
    GeoPoint geoPoint = data['location'];
    return CollectionPoint(
      id: snapshot.id,
      name: data['name'],
      description: data['description'],
      address: data['address'],
      ownerName: data['ownerName'],
      rating: data['rating'] is int ? data['rating'] : int.tryParse(data['rating'].toString()) ?? 0, // Converte string para int se necessário
      location: LatLng(geoPoint.latitude, geoPoint.longitude), // Acessa diretamente as propriedades do GeoPoint
      imageUrl: data['imageUrl'],
      materialTypes: List<String>.from(data['materialTypes']),
    );
  }
}
