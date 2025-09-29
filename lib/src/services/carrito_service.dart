import '../models/carrito_item.dart';
import '../models/producto.dart';

class CarritoService {
  static final List<CarritoItem> _items = [];

  static List<CarritoItem> obtenerItems() => _items;

  static void agregarProducto(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.nombre == producto.nombre);
    if (index != -1) {
      _items[index].cantidad++;
    } else {
      _items.add(CarritoItem(producto: producto));
    }
  }

  static double calcularTotal() {
    return _items.fold(0, (total, item) => total + item.producto.precio * item.cantidad);
  }

  static void limpiarCarrito() {
    _items.clear();
  }
}
