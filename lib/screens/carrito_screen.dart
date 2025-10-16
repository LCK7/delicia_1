import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Modelo simple de carrito en memoria (singleton)
class SimpleCart {
  SimpleCart._privateConstructor();
  static final SimpleCart instance = SimpleCart._privateConstructor();

  // items: mapa idProducto -> { id, nombre, precio, cantidad }
  final Map<String, Map<String, dynamic>> _items = {};

  List<Map<String, dynamic>> get items => _items.values.toList();

  void addItem(Map<String, dynamic> producto) {
    final id = producto['id'] ?? producto['nombre'];
    if (_items.containsKey(id)) {
      _items[id]!['cantidad'] = _items[id]!['cantidad'] + 1;
    } else {
      _items[id] = {
        'id': id,
        'nombre': producto['nombre'],
        'precio': producto['precio'],
        'cantidad': 1,
      };
    }
  }

  void removeItem(String id) {
    _items.remove(id);
  }

  void clear() {
    _items.clear();
  }

  double get total {
    double t = 0;
    for (var it in _items.values) {
      t += (it['precio'] as num) * (it['cantidad'] as int);
    }
    return t;
  }
}

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});
  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  bool _procesando = false;

  Future<void> _finalizarCompra() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes iniciar sesión para comprar')));
      return;
    }
    final items = SimpleCart.instance.items;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Carrito vacío')));
      return;
    }

    setState(() => _procesando = true);
    try {
      // Estructura: ventas: email,fecha,productos (lista de mapas con cantidad,nombre,precio), total, uid
      final venta = {
        'email': user.email,
        'fecha': FieldValue.serverTimestamp(),
        'productos': items.map((it) => {
              'cantidad': it['cantidad'],
              'nombre': it['nombre'],
              'precio': it['precio'],
            }).toList(),
        'total': SimpleCart.instance.total,
        'uid': user.uid,
      };
      await FirebaseFirestore.instance.collection('ventas').add(venta);
      SimpleCart.instance.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compra realizada con éxito')));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al procesar compra: $e')));
    } finally {
      setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = SimpleCart.instance.items;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Tu Carrito', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No hay productos en el carrito.'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final it = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.shopping_bag),
                          title: Text(it['nombre']),
                          subtitle: Text('Cantidad: ${it['cantidad']}  •  S/ ${((it['precio'] as num) * (it['cantidad'] as int)).toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                SimpleCart.instance.removeItem(it['id']);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          Text('Total: S/ ${SimpleCart.instance.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _procesando ? const CircularProgressIndicator() : Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: SimpleCart.instance.items.isEmpty ? null : _finalizarCompra,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Finalizar compra'),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    SimpleCart.instance.clear();
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('Vaciar'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
