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
}
