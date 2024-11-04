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
}
