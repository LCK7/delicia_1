import 'package:flutter/material.dart';
import 'catalogo_screen.dart';
import 'carrito_screen.dart';
import 'add_producto_screen.dart';
import 'ventas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    CatalogoScreen(),
    CarritoScreen(),
    AddProductoScreen(),
    VentasScreen(), // ← Solo visible si el usuario es admin
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.brown[800],
        unselectedItemColor: Colors.brown[300],
        backgroundColor: const Color(0xFFFFF3E0),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Agregar'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Ventas'),
        ],
      ),
    );
  }
}
