import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  User? user;
  Map<String, dynamic>? perfil;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).get();
    if (doc.exists) {
      setState(() {
        perfil = doc.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('No hay usuario autenticado.'));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          CircleAvatar(radius: 40, child: Text((perfil?['nombre'] ?? user!.email ?? 'U').toString().substring(0,1).toUpperCase())),
          const SizedBox(height: 10),
          Text(perfil?['nombre'] ?? 'Sin nombre', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(user!.email ?? '', style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone),
              title: Text(perfil?['telefono'] ?? 'No registrado'),
              subtitle: const Text('Teléfono'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(perfil?['fechaRegistro'] != null ? perfil!['fechaRegistro'].toDate().toString() : 'Fecha no disponible'),
              subtitle: const Text('Fecha de registro'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: Text((perfil?['admin'] == true) ? 'Administrador' : 'Usuario'),
              subtitle: const Text('Rol'),
            ),
          ),
        ],
      ),
    );
  }
}
