import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/services/auth_service.dart';
import 'src/screens/register_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService.usuarioActual;
    return MaterialApp(
      title: 'Panadería App',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: usuario == null ? const LoginScreen() : const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
