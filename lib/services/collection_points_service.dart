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

  Future<List<CollectionPoint>> searchCollectionPointsByName(String name) async {
    QuerySnapshot snapshot = await _firestore
        .collection('collectionPoints')
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThanOrEqualTo: name + '\uf8ff')
        .get();
    return snapshot.docs
        .map((doc) => CollectionPoint.fromFirestore(doc))
        .toList();
  }

  Future<void> deleteCollectionPoint(String id) async {
    try {
      await _firestore.collection('collectionPoints').doc(id).delete();
    } catch (e) {
      print('Erro ao excluir ponto de coleta: $e');
      throw e;
    }
  }

  Future<void> updateCollectionPoint(CollectionPoint point) async {
    try {
      await _firestore.collection('collectionPoints').doc(point.id).update({
        'name': point.name,
        'description': point.description,
        'address': point.address,
        'ownerName': point.ownerName,
        'rating': point.rating,
        'location': GeoPoint(point.location.latitude, point.location.longitude),
        'imageUrl': point.imageUrl,
        'materialTypes': point.materialTypes,
      });
    } catch (e) {
      print('Erro ao atualizar ponto de coleta: $e');
      throw e;
    }
  }
}