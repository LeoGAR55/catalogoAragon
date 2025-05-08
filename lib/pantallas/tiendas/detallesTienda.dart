import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clases/tienda.dart';
// clase para mostrar los detalles de una tienda al oprimirla en segunda pantalla
class TiendaDetalleScreen extends StatelessWidget {
  final Tienda tienda; // tienda que vamos a mostrar

  const TiendaDetalleScreen({required this.tienda}); // constructor
  // func asincrona
  Future<List<Producto>> obtenerProductos() async { // obtener los productos de firebase
    // todo esto es para jalar la subcoleccion que esta en cada tienda
    // ej: /tiendas/tienda_01/productos/UtRNmHkC6bgQqDSbvMZ7
    final snapshot = await FirebaseFirestore.instance
        .collection('tiendas')
        .doc(tienda.id)
        .collection('productos')
        .get();
    // convertir el map de firebase a nuestra clase producto
    return snapshot.docs
        .map((doc) => Producto.fromMap(doc.data()))
        .toList();
  }
  // interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tienda.nombre)), // barra de arriba
      // CUERPO
      body: Column(
        children: [
          Image.network( // imagen cropeada para que se vea arriba
            tienda.imagenUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 100),
          ),
          SizedBox(height: 16),
          Text(
            'Menú de productos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // CONTENEDOR DE PRODUCTOS --------------------------------
          Expanded(
            child: FutureBuilder<List<Producto>>(
              future: obtenerProductos(), // obtener prod
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) // rueda de carga
                  return Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return Center(child: Text('Error al cargar productos'));
                final productos = snapshot.data ?? [];

                if (productos.isEmpty) {
                  return Center(child: Text('No hay productos disponibles'));
                }
                // debugs como en tienda porque no me cargaban, verificar campos en los docs de firebase
                return ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return ListTile( // mostrar informacion en una sola fila
                      title: Text(producto.nombre),
                      trailing: Text('\$${producto.precio.toStringAsFixed(2)}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
