import 'package:flutter/material.dart';
import '../services/producto_service.dart';
import '../widgets/producto_card.dart';
import '../models/producto.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        title: const Text('Catálogo de Panadería'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar producto...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => setState(() => _busqueda = value.toLowerCase()),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Producto>>(
                stream: ProductoService.obtenerProductosStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF6D4C41)),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar productos'));
                  }

                  final productos = snapshot.data ?? [];
                  final filtrados = productos
                      .where((p) => p.nombre.toLowerCase().contains(_busqueda))
                      .toList();

                  if (filtrados.isEmpty) {
                    return const Center(child: Text('No hay productos disponibles.'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.8, // 👈 más espacio vertical
                      ),
                      itemCount: filtrados.length,
                      itemBuilder: (context, i) => ProductoCard(producto: filtrados[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
