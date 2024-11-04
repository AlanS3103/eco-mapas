import '../models/collection_point.dart';
import 'package:latlong2/latlong.dart';

class CollectionPointsService {
  static List<CollectionPoint> getCollectionPoints() {
    return [
      CollectionPoint(
        id: '1',
        name: 'Ecoponto Central',
        description:
            'Centro de reciclagem de materiais tecnológicos e eletrônicos',
        address: 'Rua Fritz Jacobs, 1322 - Boa Vista, São José do Rio Preto',
        ownerName: 'Henrique Dezani',
        rating: 148,
        location: LatLng(-20.819724, -49.379852),
        imageUrl: 'https://i.postimg.cc/QNBKdBy0/ecoponto.jpg',
        materialTypes: ['Eletrônicos', 'Baterias', 'Computadores'],
      ),
    ];
  }
}
