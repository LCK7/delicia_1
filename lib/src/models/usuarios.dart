class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String telefono;
  final String rol; // 'admin' o 'cliente'

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
  });

  factory Usuario.fromMap(Map<String, dynamic> data) {
    return Usuario(
      uid: data['uid'] ?? '',
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? '',
      rol: data['rol'] ?? 'cliente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'rol': rol,
    };
  }
}
