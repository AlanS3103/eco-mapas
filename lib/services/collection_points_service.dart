import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/collection_point.dart';

class CollectionPointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CollectionPoint>> getCollectionPoints() async {
    QuerySnapshot snapshot =
        await _firestore.collection('collectionPoints').get();
    return snapshot.docs
        .map((doc) => CollectionPoint.fromFirestore(doc))
        .toList();
  }

  Future<void> addCollectionPoint(CollectionPoint point) async {
    await _firestore.collection('collectionPoints').add({
      'id': point.id,
      'name': point.name,
      'description': point.description,
      'address': point.address,
      'ownerName': point.ownerName,
      'rating': point.rating,
      'location': GeoPoint(point.location.latitude, point.location.longitude),
      'imageUrl': point.imageUrl,
      'materialTypes': point.materialTypes,
    });
  }
}
