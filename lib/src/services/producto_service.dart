import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';

class ProductoService {
  static Future<List<Producto>> obtenerProductos() async {
    final snapshot = await FirebaseFirestore.instance.collection('productos').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Producto(
        nombre: data['nombre'],
        descripcion: data['descripcion'],
        precio: (data['precio'] as num).toDouble(),
        imagenUrl: data['imagenUrl'],
      );
    }).toList();
  }
}
