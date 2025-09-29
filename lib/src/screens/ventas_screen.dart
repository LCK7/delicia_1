import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VentasScreen extends StatelessWidget {
  const VentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        title: const Text('Ventas realizadas', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ventas').orderBy('fecha', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6D4C41)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.', style: TextStyle(color: Color(0xFF6D4C41))));
          }
          final ventas = snapshot.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ventas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final venta = ventas[index].data() as Map<String, dynamic>;
              final productos = venta['productos'] as List<dynamic>? ?? [];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Usuario: ${venta['email'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Fecha: ${venta['fecha']?.toDate().toString().substring(0, 19) ?? ''}', style: const TextStyle(color: Colors.brown)),
                      Text('Total: S/. ${venta['total']?.toStringAsFixed(2) ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Productos:', style: TextStyle(decoration: TextDecoration.underline)),
                      ...productos.map((p) => Text('- ${p['nombre']} x${p['cantidad']} (S/. ${p['precio']})')).toList(),
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
