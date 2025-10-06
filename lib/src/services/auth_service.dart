import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static User? get usuarioActual => _auth.currentUser;

  static Future<bool> esAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    // Aquí puedes consultar Firestore si el usuario tiene rol "admin"
    // Por ahora devolvemos false por defecto
    return false;
  }

  static Future<void> cerrarSesion() async {
    await _auth.signOut();
  }
}
