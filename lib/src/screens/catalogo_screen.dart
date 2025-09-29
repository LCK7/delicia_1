import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';
import '../widgets/producto_card.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  late Future<List<Producto>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = ProductoService.obtenerProductos();
  }

  Future<bool> _esAdmin(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    return doc.exists && (doc.data()?['admin'] == true);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: FutureBuilder<List<Producto>>(
        future: _productosFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: const Color(0xFF6D4C41),
                    pinned: true,
                    expandedHeight: 140,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Catálogo de Panadería',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (user != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${user.displayName ?? ''} | ${user.email}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      centerTitle: true,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        tooltip: 'Carrito de compras',
                        onPressed: () => Navigator.pushNamed(context, '/carrito'),
                      ),
                      if (user == null)
                        IconButton(
                          icon: const Icon(Icons.login),
                          tooltip: 'Iniciar sesión',
                          onPressed: () => Navigator.pushNamed(context, '/login'),
                        ),
                      if (user != null)
                        IconButton(
                          icon: const Icon(Icons.logout),
                          tooltip: 'Cerrar sesión',
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sesión cerrada'),
                                backgroundColor: Color(0xFF6D4C41),
                              ),
                            );
                            Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                    ],
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF6D4C41)),
                      ),
                    )
                  else if (snapshot.hasError)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Error al cargar productos',
                          style: TextStyle(color: Color(0xFF6D4C41)),
                        ),
                      ),
                    )
                  else if ((snapshot.data ?? []).isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No hay productos disponibles.',
                          style: TextStyle(color: Color(0xFF6D4C41)),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final producto = snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: const Color(0xFFFFF3E0),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: ProductoCard(producto: producto),
                                ),
                              ),
                            );
                          },
                          childCount: snapshot.data!.length,
                        ),
                      ),
                    ),
                ],
              ),
              if (user != null)
                FutureBuilder<bool>(
                  future: _esAdmin(user.uid),
                  builder: (context, adminSnapshot) {
                    if (adminSnapshot.connectionState != ConnectionState.done || adminSnapshot.data != true) {
                      return const SizedBox.shrink();
                    }
                    return Positioned(
                      right: 24,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FloatingActionButton.extended(
                            backgroundColor: Colors.green,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Añadir producto', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.pushNamed(context, '/add_producto');
                            },
                          ),
                          const SizedBox(height: 12),
                          FloatingActionButton.extended(
                            backgroundColor: Colors.brown,
                            icon: const Icon(Icons.receipt_long, color: Colors.white),
                            label: const Text('Ver ventas', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.pushNamed(context, '/ventas');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
