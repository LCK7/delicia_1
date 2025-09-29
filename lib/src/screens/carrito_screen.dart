import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/carrito_service.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final items = CarritoService.obtenerItems();
  final total = CarritoService.calcularTotal();
  final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        title: const Text('Carrito de Compras', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Tu carrito está vacío.', style: TextStyle(color: Color(0xFF6D4C41), fontSize: 18)))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(item.producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Cantidad: ${item.cantidad}'),
                            trailing: Text('S/. ${(item.producto.precio * item.cantidad).toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Total: S/. ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6D4C41))),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D4C41),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text('Comprar', style: TextStyle(color: Colors.white, fontSize: 18)),
                    onPressed: items.isEmpty
                        ? null
                        : () async {
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Debes iniciar sesión o registrarte para comprar.'), backgroundColor: Colors.red),
                              );
                              Navigator.pushNamed(context, '/login');
                              return;
                            }
                            // Guardar venta en Firestore
                            final productosVenta = items.map((item) => {
                              'nombre': item.producto.nombre,
                              'cantidad': item.cantidad,
                              'precio': item.producto.precio,
                            }).toList();
                            await FirebaseFirestore.instance.collection('ventas').add({
                              'uid': user.uid,
                              'email': user.email,
                              'productos': productosVenta,
                              'total': total,
                              'fecha': DateTime.now(),
                            });
                            CarritoService.limpiarCarrito();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('¡Compra realizada con éxito!'), backgroundColor: Color(0xFF6D4C41)),
                            );
                            Navigator.pop(context);
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
