import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// clase para mostrar los productos obtenidos en la busqueda
class ResultadoProducto {
  final String nombreProducto;
  final double precio;
  final String nombreTienda;
  final String idTienda;

  ResultadoProducto({ // constructor
    required this.nombreProducto,
    required this.precio,
    required this.nombreTienda,
    required this.idTienda,
  });
}

// checar doc de future builder : https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html
// future builder es un widget que ejecuta una tarea asincrona, va a esperar un resultado y despues
// lo va a mostrar

// clase para manejar la busqueda de productos
class TiendaSearchDelegate extends SearchDelegate {
  // funcion para buscar en firestone los productos
  Future<List<ResultadoProducto>> buscarProductos(String query) async {
    // traer todas las tiendas
    final tiendasSnapshot = await FirebaseFirestore.instance.collection('tiendas').get();
    List<ResultadoProducto> resultados = [];
    // recorremos todas las tiendas
    for (var tiendaDoc in tiendasSnapshot.docs) {
      final tiendaId = tiendaDoc.id;
      final tiendaNombre = tiendaDoc.data()['nombre'] ?? 'Tienda sin nombre';
      // obetenmos todos los productos de la suboleccion
      final productosSnapshot = await FirebaseFirestore.instance
          .collection('tiendas')
          .doc(tiendaId)
          .collection('productos')
          .get();

      for (var productoDoc in productosSnapshot.docs) {
        final data = productoDoc.data();
        final nombreProducto = data['nombre']?.toString().toLowerCase() ?? ''; // convertor a min

        if (nombreProducto.contains(query.toLowerCase())) {
          resultados.add(ResultadoProducto(
            nombreProducto: data['nombre'],
            precio: (data['precio'] as num).toDouble(),
            nombreTienda: tiendaNombre,
            idTienda: tiendaId,
          ));
        }
      }
    }

    return resultados;
  }
  // tache a la derecha al hacer una busqueda para borrarla
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // seteamos a nada el textfield
        },
      ),
    ];
  }
// boton para regresar (izq en el textfield de busqueda)
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // muestra los resultados de la busqueda
    return FutureBuilder<List<ResultadoProducto>>(
      future: buscarProductos(query), // buscar los productos que coincidan con el query
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al buscar productos'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No se encontraron productos'));
        }

        final resultados = snapshot.data!;

        return ListView.builder(
          itemCount: resultados.length,
          itemBuilder: (context, index) {
            final producto = resultados[index];
            return ListTile(
              title: Text(producto.nombreProducto),
              subtitle: Text('Tienda: ${producto.nombreTienda}'),
              trailing: Text('\$${producto.precio.toStringAsFixed(2)}'),
            );
          },
        );
      },
    );
  }

  @override // si borro esta funcion se vuelve loco el ide
  // al parecer esta clase abstracta requiere el metodo
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    throw UnimplementedError();
  }
}
