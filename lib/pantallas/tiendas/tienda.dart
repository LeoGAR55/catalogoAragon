// clase que representa un producto con los campos nombre y precio
class Producto {
  final String nombre;
  final double precio;

  // constructor
  Producto({required this.nombre, required this.precio});

  // metodo que crea un producto a partir de un dict
  factory Producto.fromMap(Map<String, dynamic> data) {
    try {
      return Producto(
        nombre: data['nombre'] ?? 'Sin nombre', // usa 'sin nombre' si no se encuentra el campo
        precio: (data['precio'] as num).toDouble(), // convertir de number a double
      );
    } catch (e) {
      // si ocurre un error, imprime el error y devuelve un producto de emergencia
      print("❌ Error al crear producto: $e");
      return Producto(nombre: 'Error', precio: 0.0);
    }
  }
}

// clase tienda n
class Tienda {
  final String id;
  final String nombre;
  final String imagenUrl;

  // constructor de la tienda
  Tienda({required this.id, required this.nombre, required this.imagenUrl});

  // metodo para crear la tienda a partir del map de firestone
  factory Tienda.fromFirestore(String id, Map<String, dynamic> data) {
    try {
      return Tienda(
        id: id, // usa el id que nos da firestone
        nombre: data['nombre'] ?? 'Nombre no disponible', // nombre por defecto si no existe
        imagenUrl: data['imagenUrl'] ?? '', // imagen vacía si no existe el campo
      );
    } catch (e) {
      // si ocurre un error, imprime el error y lo relanza
      print("Error al crear tienda desde Firestore: $e");
      rethrow;
    }
  }
}
