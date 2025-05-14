import 'dart:ui'; // para trabajar con Offset

// clase que representa un producto con los campos nombre y precio
class Producto {
  final String nombre;
  final double precio;

  Producto({required this.nombre, required this.precio});

  factory Producto.fromMap(Map<String, dynamic> data) {
    try {
      return Producto(
        nombre: data['nombre'] ?? 'Sin nombre',
        precio: (data['precio'] as num).toDouble(),
      );
    } catch (e) {
      print("error creando productos: $e");
      return Producto(nombre: 'Error', precio: 0.0);
    }
  }
}

// clase tienda n
class Tienda {
  final String id; //estos 3 primeros atributos vienen de Firestore
  final String nombre;
  final String imagenUrl;
  final double cordx; // estas 2 coordenadas indican la posicion de la tienda en el widget de imagenInteractiva
  final double cordy;

  // constructor de la tienda con todos los campos
  Tienda({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    this.cordx = 0,
    this.cordy = 0,
  });

  // metodo para crear la tienda a partir del map de Firestore
  // https://stackoverflow.com/questions/69990793/how-to-use-a-factory-constructor-with-null-safety
  // con el constructor factory nos aseguramos que los objetos de firebase vengan con los campos correctos
  // y si no tiramos un error
  factory Tienda.fromMap(String id, Map<String, dynamic> data) {
    try {
      // Asegúrate de que los valores no sean null antes de usarlos
      final nombre = data['nombre'] ?? 'Nombre no disponible';  // nombre por defecto si no existe
      final imagenUrl = data['imagenUrl'] ?? '';  // imagen vacía si no existe el campo

      return Tienda(
        id: id,
        nombre: nombre,
        imagenUrl: imagenUrl,
      );
    } catch (e) {
      // si hay un error:
      print("Error al crear tienda desde Firestore: $e");
      rethrow;
    }
  }

  // para trabajar en imagen interactiva
  // la tienda de la imagen vien con la pos x y y
  factory Tienda.conPosicion({
    required String id,
    required String nombre,
    required String imagenUrl,
    required Offset posicion,
  }) {
    return Tienda(
      id: id,
      nombre: nombre,
      imagenUrl: imagenUrl,
      cordx: posicion.dx,
      cordy: posicion.dy,
    );
  }
}
