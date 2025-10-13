import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'carrito_screen.dart'; // para usar el modelo carrito singleton si necesitas acceso (está en el mismo archivo)

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  void _agregarAlCarrito(BuildContext context, Map<String, dynamic> producto) {
    // Usamos el carrito global
    SimpleCart.instance.addItem(producto);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto agregado al carrito')));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('productos').orderBy('nombre').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
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
              'precio': (p['precio'] is int) ? (p['precio'] as int).toDouble() : (p['precio'] as num).toDouble(),
            };
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.bakery_dining),
                title: Text(producto['nombre']),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(producto['descripcion'] ?? ''),
                  const SizedBox(height: 4),
                  Text('S/ ${producto['precio'].toStringAsFixed(2)}'),
                ]),
                trailing: ElevatedButton(
                  onPressed: () => _agregarAlCarrito(context, producto),
                  child: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
