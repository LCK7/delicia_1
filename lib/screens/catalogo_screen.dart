import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'carrito_screen.dart';

String convertirEnlaceDriveADirecto(String enlaceDrive) {
  final regExp1 = RegExp(r'/d/([a-zA-Z0-9_-]+)');
  final match1 = regExp1.firstMatch(enlaceDrive);

  // Caso 2: formato ?id=ID
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

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  void _agregarAlCarrito(BuildContext context, Map<String, dynamic> producto) {
    SimpleCart.instance.addItem(producto);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto agregado al carrito')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final p = docs[index];
            final producto = {
              'id': p.id,
              'nombre': p['nombre'],
              'descripcion': p['descripcion'],
              'precio': (p['precio'] is int)
                  ? (p['precio'] as int).toDouble()
                  : (p['precio'] as num).toDouble(),
              'imagen': p['imagen'] ?? '',
            };

            final urlImagen = convertirEnlaceDriveADirecto(producto['imagen']);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                // 🔹 Mostrar imagen si existe, de lo contrario un ícono por defecto
                leading: urlImagen.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          urlImagen,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 40),
                        ),
                      )
                    : const Icon(Icons.bakery_dining, size: 40),

                title: Text(producto['nombre']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(producto['descripcion'] ?? ''),
                    const SizedBox(height: 4),
                    Text('S/ ${producto['precio'].toStringAsFixed(2)}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () => _agregarAlCarrito(context, producto),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Agregar'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
