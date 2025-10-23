import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'carrito_screen.dart';

String convertirEnlaceDriveADirecto(String enlaceDrive) {
  final regExp1 = RegExp(r'/d/([a-zA-Z0-9_-]+)');
  final match1 = regExp1.firstMatch(enlaceDrive);

  final regExp2 = RegExp(r'id=([a-zA-Z0-9_-]+)');
  final match2 = regExp2.firstMatch(enlaceDrive);

  String? id;
  if (match1 != null) {
    id = match1.group(1);
  } else if (match2 != null) {
    id = match2.group(1);
  }

  if (id != null) {
    return 'https://drive.google.com/uc?export=view&id=$id';
  } else {
    return enlaceDrive;
  }
}

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  _CatalogoScreenState createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  // Controlador para el texto de búsqueda
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _agregarAlCarrito(BuildContext context, Map<String, dynamic> producto) {
    if (producto['stock'] == null || producto['stock'] <= 0) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('No hay stock disponible para este producto'),
            duration: Duration(seconds: 1),
          ),
        );
      return;
    }
    SimpleCart.instance.addItem(producto);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Producto agregado al carrito'),
          duration: Duration(seconds: 1),
        ),
      );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('productos')
            .orderBy('nombre')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay productos disponibles.'),
            );
          }
          final filteredDocs = docs.where((p) {
            final producto = p.data() as Map<String, dynamic>;
            final nombre = producto['nombre'].toLowerCase();
            final descripcion = producto['descripcion']?.toLowerCase() ?? '';
            return nombre.contains(_searchQuery) || descripcion.contains(_searchQuery);
          }).toList();

          if (filteredDocs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No se encontraron productos con esa búsqueda.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final p = filteredDocs[index];
              final producto = {
                'id': p.id,
                'nombre': p['nombre'],
                'descripcion': p['descripcion'],
                'precio': (p['precio'] is int)
                    ? (p['precio'] as int).toDouble()
                    : (p['precio'] as num).toDouble(),
                'imagen': p['imagen'] ?? '',
                'stock': p['stock'] ?? 0,
              };

              final urlImagen = convertirEnlaceDriveADirecto(producto['imagen']);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      urlImagen.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                urlImagen,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 40),
                              ),
                            )
                          : const Icon(Icons.bakery_dining, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        producto['nombre'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(producto['descripcion'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Text(
                        'S/ ${producto['precio'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stock disponible: ${producto['stock']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: producto['stock'] == 0
                              ? Colors.red
                              : (producto['stock'] < 10 ? Colors.orange : Colors.green),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _agregarAlCarrito(context, producto),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Agregar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
