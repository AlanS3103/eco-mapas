import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/collection_point.dart';
import '../services/collection_points_service.dart';
import '../widgets/custom_map_marker.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final MapController mapController = MapController();
  // Coordenadas de São José do Rio Preto
  final LatLng initialPosition = LatLng(-20.819724, -49.379852);
  late List<CollectionPoint> collectionPoints =
      []; // Inicialize com uma lista vazia
  late CollectionPointsService _collectionPointsService; // Crie uma instância
  bool _isLoading = true; // Adicione um indicador de carregamento

  @override
  void initState() {
    super.initState();
    _collectionPointsService =
        CollectionPointsService(); // Inicialize a instância
    _loadCollectionPoints(); // Chama o método para carregar os pontos
  }

  Future<void> _loadCollectionPoints() async {
    try {
      collectionPoints = await _collectionPointsService.getCollectionPoints();
      if (collectionPoints.isEmpty) {
        print('Nenhum ponto de coleta encontrado.');
      } else {
        print('Pontos de coleta carregados: ${collectionPoints.length}');
      }
    } catch (e) {
      print('Erro ao carregar pontos de coleta: $e');
    }
    setState(() {
      _isLoading = false; // Atualize o estado de carregamento
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Exibe o indicador de carregamento
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(-20.819724, -49.379852),
                initialZoom: 13.0,
                minZoom: 3.0,
                maxZoom: 18.0,
                onLongPress: (tapPosition, point) {
                  _showAddPointModal(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.eco_mapas',
                ),
                MarkerLayer(
                  markers:
                      _buildMarkers(), // Chama o método para construir marcadores
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              mapController.move(initialPosition, 13.0);
            },
            child: const Icon(Icons.center_focus_strong),
            heroTag: 'center',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _showAddPointModal(initialPosition),
            child: const Icon(Icons.add_location),
            heroTag: 'add',
          ),
        ],
      ),
    );
  }

  void addNewPoint(CollectionPoint newPoint) async {
    try {
      await _collectionPointsService.addCollectionPoint(newPoint);
      setState(() {
        collectionPoints.add(newPoint);
      });
    } catch (e) {
      print('Erro ao adicionar ponto de coleta: $e');
    }
  }

  void _showAddPointModal(LatLng initialLocation) {
    String name = '';
    String address = '';
    String description = '';
    List<String> materialTypes = [];
    String ownerName = '';
    String imageUrl = '';
    LatLng location = initialLocation; // Use a localização inicial fornecida

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(labelText: 'Nome'),
                      onChanged: (value) => name = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Endereço'),
                      onChanged: (value) => address = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Descrição'),
                      onChanged: (value) => description = value,
                    ),
                    TextField(
                      decoration: InputDecoration(
                          labelText:
                              'Tipos de Material (separados por vírgula)'),
                      onChanged: (value) => materialTypes =
                          value.split(',').map((e) => e.trim()).toList(),
                    ),
                    TextField(
                      decoration:
                          InputDecoration(labelText: 'Nome do Proprietário'),
                      onChanged: (value) => ownerName = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'URL da Imagem'),
                      onChanged: (value) => imageUrl = value,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text('Adicionar Ponto'),
                      onPressed: () {
                        addNewPoint(CollectionPoint(
                          id: (collectionPoints.length + 1).toString(),
                          name: name,
                          description: description,
                          address: address,
                          ownerName: ownerName,
                          rating: 0, // Inicialmente sem avaliação
                          location: location, // Use a localização selecionada
                          imageUrl: imageUrl.isNotEmpty
                              ? imageUrl
                              : 'https://example.com/placeholder.jpg', // Placeholder
                          materialTypes: materialTypes,
                        ));
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.green,
        ),
      ),
      title: TextField(
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          hintText: 'Buscar...',
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          // Implementar busca
        },
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pushNamed(context, "/configuracoes");
            },
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: const Text('Ajuda'),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return collectionPoints.map((point) {
      return Marker(
        point: point.location,
        width: 60.0,
        height: 60.0,
        child: GestureDetector(
          onTap: () => _showLocationDetails(context, point),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.recycling,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showLocationDetails(BuildContext context, CollectionPoint point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    point.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      point.address,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sobre',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      point.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: point.materialTypes
                          .map((type) => Chip(
                                label: Text(type),
                                backgroundColor: Colors.green[100],
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, color: Colors.grey[600]),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ANUNCIADO POR:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              point.ownerName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Icon(Icons.star,
                                color: Colors.yellow[700], size: 20),
                            SizedBox(width: 4),
                            Text(
                              point.rating.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
