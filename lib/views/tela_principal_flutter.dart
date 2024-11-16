import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../firebase_auth_implementation/firebase_auth_services.dart';
import '../models/collection_point.dart';
import '../services/collection_points_service.dart';
// import '../widgets/custom_map_marker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'tela_perfil_flutter.dart';

class PrincipalScreen extends StatefulWidget {
  final String userType;

  const PrincipalScreen({super.key, required this.userType});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  final MapController mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final LatLng initialPosition = LatLng(-20.819724, -49.379852);
  late List<CollectionPoint> collectionPoints = [];
  late CollectionPointsService _collectionPointsService;
  bool _isLoading = true;
  bool _isAddingPoint = false;
  String imageUrl = '';
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _collectionPointsService =
        CollectionPointsService(); // Inicialize a instância
    _loadCollectionPoints(); // Chama o método para carregar os pontos
    _getCurrentLocation();
  }

  @override
  void dispose() {
    mapController.dispose();
    _searchController.dispose();
    super.dispose();
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
    if (mounted) {
      setState(() {
        _isLoading = false; // Atualize o estado de carregamento
      });
    }
  }

  Future<void> _searchCollectionPoints(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      collectionPoints =
          await _collectionPointsService.searchCollectionPointsByName(query);
      if (collectionPoints.isEmpty) {
        print('Nenhum ponto de coleta encontrado.');
      } else {
        print('Pontos de coleta carregados: ${collectionPoints.length}');
      }
    } catch (e) {
      print('Erro ao carregar pontos de coleta: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _uploadImage(File(pickedFile.path));
    } else {
      print('Nenhuma imagem selecionada.');
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _uploadImage(File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('imgCollectionPoint/${DateTime.now().toIso8601String()}');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('Erro: Objeto não encontrado.');
      } else if (e.code == 'unauthorized') {
        print('Erro: Não autorizado.');
      } else if (e.code == 'cancelled') {
        print('Erro: Upload cancelado.');
      } else {
        print('Erro desconhecido: $e');
      }
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
    }
    return null;
  }

  Future<void> _refreshMap() async {
    setState(() {
      _isLoading = true;
    });
    await _loadCollectionPoints();
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
                onLongPress: widget.userType == 'empresa'
                    ? (tapPosition, point) {
                        _showAddPointModal(point);
                      }
                    : null,
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
                if (currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLocation!,
                        width: 80.0,
                        height: 80.0,
                        child: Container(
                          child: Icon(
                            Icons.circle,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _refreshMap,
            child: const Icon(Icons.refresh),
            heroTag: 'refresh',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _centerOnUserLocation,
            child: const Icon(Icons.center_focus_strong),
            heroTag: 'center',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _resetRotation,
            child: const Icon(Icons.explore),
            heroTag: 'reset_rotation',
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
    mapController.move(currentLocation!, 13.0);
  }

  Future<void> _centerOnUserLocation() async {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 13.0);
    } else {
      await _getCurrentLocation();
    }
  }

  void _resetRotation() {
    mapController.rotate(0);
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
    List<String> selectedMaterials = [];
    String ownerName = '';
    String imageUrl = '';
    LatLng location = initialLocation;
    File? selectedImage;
    final _formKey = GlobalKey<FormState>();

    final List<String> availableMaterials = [
      'Garrafas PET',
      'Baterias de carro',
      'Baterias recarregáveis',
      'Alumínio',
      'Pilhas',
      'Papelão',
      'Metais',
      'Lâmpadas fluorescentes',
      'Telefones celulares',
      'Óleos de motor',
      'Roupas e calçados',
      'Orgânicos',
      'Papel',
      'Plástico',
      'Eletrodomésticos',
      'Filme de polietileno',
      'Sacolas de polietileno',
      'Óleo vegetal',
      'Vidro',
      'Termômetros e lâmpadas de baixo consumo de energia',
      'Pneus'
    ];

    void _showMaterialSelector() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Selecione os Materiais'),
            content: Container(
              width: double.maxFinite,
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: availableMaterials.map((material) {
                        return CheckboxListTile(
                          title: Text(material),
                          value: selectedMaterials.contains(material),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedMaterials.add(material);
                              } else {
                                selectedMaterials.remove(material);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text('Confirmar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Adicionar Novo Ponto de Coleta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira um nome';
                          }
                          return null;
                        },
                        onChanged: (value) => name = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Endereço',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira um endereço';
                          }
                          return null;
                        },
                        onChanged: (value) => address = value,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Descrição',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira uma descrição';
                          }
                          return null;
                        },
                        onChanged: (value) => description = value,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.recycling),
                        label: Text('Selecionar Tipos de Material'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _showMaterialSelector,
                      ),
                      if (selectedMaterials.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            children: selectedMaterials
                                .map((material) => Chip(
                                      label: Text(material),
                                      onDeleted: () {
                                        setState(() {
                                          selectedMaterials.remove(material);
                                        });
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nome do Proprietário',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome do proprietário';
                          }
                          return null;
                        },
                        onChanged: (value) => ownerName = value,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.photo_library),
                              label: Text('Galeria'),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (pickedFile != null) {
                                  setState(() {
                                    selectedImage = File(pickedFile.path);
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.camera_alt),
                              label: Text('Câmera'),
                              onPressed: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                  source: ImageSource.camera,
                                );
                                if (pickedFile != null) {
                                  setState(() {
                                    selectedImage = File(pickedFile.path);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      _isAddingPoint
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text('Adicionar Ponto'),
                              onPressed: () async {
                                if (_formKey.currentState!.validate() &&
                                    selectedMaterials.isNotEmpty &&
                                    selectedImage != null) {
                                  setState(() {
                                    _isAddingPoint = true;
                                  });
                                  imageUrl =
                                      await _uploadImage(selectedImage!) ?? '';
                                  addNewPoint(CollectionPoint(
                                    id: (collectionPoints.length + 1)
                                        .toString(),
                                    name: name,
                                    description: description,
                                    address: address,
                                    ownerName: ownerName,
                                    rating: 0,
                                    location: location,
                                    imageUrl: imageUrl.isNotEmpty
                                        ? imageUrl
                                        : 'https://example.com/placeholder.jpg',
                                    materialTypes: selectedMaterials,
                                  ));
                                  setState(() {
                                    _isAddingPoint = false;
                                  });
                                  Navigator.pop(context);
                                } else if (selectedMaterials.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Selecione pelo menos um tipo de material'),
                                    ),
                                  );
                                } else if (selectedImage == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Selecione uma imagem para o ponto'),
                                    ),
                                  );
                                }
                              },
                            ),
                      SizedBox(height: 16),
                    ],
                  ),
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
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          hintText: 'Buscar...',
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
        onChanged: (value) {
          _searchCollectionPoints(value);
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TelaPerfil(userType: widget.userType)),
              );
            },
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
            onTap: () {
              Navigator.pushNamed(context, "/ajuda");
            },
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
            onTap: () async {
              await FirebaseAuthServices().signOut();
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
          child: ListView(
            // Use um ListView em vez de um Column
            padding: const EdgeInsets.all(16.0),
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
