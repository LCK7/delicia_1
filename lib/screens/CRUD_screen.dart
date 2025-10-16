import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CRUDScreen extends StatefulWidget {
  const CRUDScreen({super.key});
  @override
  State<CRUDScreen> createState() => _CRUDScreenState();
}

class _CRUDScreenState extends State<CRUDScreen> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _precio = TextEditingController();
  final TextEditingController _imagen = TextEditingController();

  String? _idSeleccionado;

  @override
  void initState() {
    super.initState();
  }

  Future<void> createProducto() async {
    if (!_validarCampos()) return;
    final datos = {
      'nombre': _nombre.text.trim(),
      'descripcion': _descripcion.text.trim(),
      'precio': double.tryParse(_precio.text) ?? 0.0,
      'imagen': _imagen.text.trim(),
    };
    try {
      await FirebaseFirestore.instance.collection('productos').add(datos);
      limpiarFormulario();
    } catch (e) {
      print('Error al crear producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear producto: $e')));
    }
  }

  Future<void> updateProducto(String id) async {
    if (!_validarCampos()) return;
    final datos = {
      'nombre': _nombre.text.trim(),
      'descripcion': _descripcion.text.trim(),
      'precio': double.tryParse(_precio.text) ?? 0.0,
      'imagen': _imagen.text.trim(),
    };
    try {
      await FirebaseFirestore.instance.collection('productos').doc(id).update(datos);
      limpiarFormulario();
    } catch (e) {
      print('Error al actualizar producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar producto: $e')));
    }
  }

  Future<void> deleteProducto(String id) async {
    try {
      await FirebaseFirestore.instance.collection('productos').doc(id).delete();
      limpiarFormulario();
    } catch (e) {
      print('Error al eliminar producto: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar producto: $e')));
    }
  }

  void limpiarFormulario() {
    setState(() {
      _nombre.clear();
      _descripcion.clear();
      _precio.clear();
      _imagen.clear();
      _idSeleccionado = null;
    });
  }

  bool _validarCampos() {
    if (_nombre.text.isEmpty || _descripcion.text.isEmpty || _precio.text.isEmpty||_imagen.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return false;
    }
    final precio = double.tryParse(_precio.text);
    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio debe ser mayor que 0')),
      );
      return false;
    }
    if (!_imagen.text.contains('drive.google.com')){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un enlace valido de Google Drive')),
      );
    }
    return true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _imagen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nombre,
            decoration: const InputDecoration(
              labelText: "Nombre del producto",
              icon: Icon(Icons.category),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descripcion,
            decoration: const InputDecoration(
              labelText: "Descripción",
              icon: Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _precio,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Precio (S/.)",
              icon: Icon(Icons.monetization_on),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _imagen,
            decoration: const InputDecoration(
              labelText: "Enlace de imagen (Drive)",
              icon: Icon(Icons.image),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              if (_idSeleccionado == null) {
                createProducto();
              } else {
                updateProducto(_idSeleccionado!);
              }
            },
            icon: Icon(_idSeleccionado == null ? Icons.add : Icons.save),
            label: Text(_idSeleccionado == null ? 'Agregar Producto' : 'Actualizar Producto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _idSeleccionado == null ? Colors.green : Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1),
          const SizedBox(height: 10),
          const Text('Lista de Productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('productos').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay productos registrados.'),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final producto = docs[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.bakery_dining),
                      title: Text(producto['nombre']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(producto['descripcion'] ?? ''),
                          Text('Precio: S/. ${producto['precio'].toString()}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              setState(() {
                                _idSeleccionado = producto.id;
                                _nombre.text = producto['nombre'];
                                _descripcion.text = producto['descripcion'] ?? '';
                                _precio.text = producto['precio'].toString();
                                _imagen.text = producto['imagen'] ?? '';
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteProducto(producto.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
