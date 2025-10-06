class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
  });

  factory Producto.fromMap(Map<String, dynamic> data, String documentId) {
    return Producto(
      id: documentId,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      imagenUrl: data['imagenUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
    };
  }
}
