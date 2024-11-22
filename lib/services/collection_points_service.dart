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
    DocumentReference docRef =
        await _firestore.collection('collectionPoints').add({
      //'id': docRef.id,
      'name': point.name,
      'description': point.description,
      'address': point.address,
      'ownerName': point.ownerName,
      'rating': point.rating,
      'location': GeoPoint(point.location.latitude, point.location.longitude),
      'imageUrl': point.imageUrl,
      'materialTypes': point.materialTypes,
    });
    // Atualize o ID do ponto de coleta com o ID gerado automaticamente
    await docRef.update({'id': docRef.id});
    point.id = docRef.id;
  }

  Future<List<CollectionPoint>> searchCollectionPointsByName(
      String name) async {
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
    DocumentSnapshot doc = await _firestore.collection('collectionPoints').doc(point.id).get();

    if (doc.exists) {
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
    } else {
      print('Documento não encontrado. ID: ${point.id}');
      throw Exception('Documento não encontrado');
    }
  } catch (e) {
    print('Erro ao atualizar ponto de coleta: $e');
    throw e;
  }
}
}
