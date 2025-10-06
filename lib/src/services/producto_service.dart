import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';

class ProductoService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'productos';

  static Stream<List<Producto>> obtenerProductosStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Producto.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<List<Producto>> obtenerProductos() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      return snapshot.docs
          .map((doc) => Producto.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error al obtener productos: $e');
      return [];
    }
  }

  static Future<void> agregarProducto(Producto producto) async {
    await _db.collection(_collection).add(producto.toMap());
  }

  static Future<void> actualizarProducto(String id, Producto producto) async {
    await _db.collection(_collection).doc(id).update(producto.toMap());
  }

  static Future<Producto?> obtenerProductoPorId(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Producto.fromMap(doc.data()!, doc.id);
  }
}
