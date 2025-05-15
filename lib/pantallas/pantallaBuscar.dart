import 'package:flutter/material.dart';
import 'package:catalogo/clases/busquedaProducto.dart'; // tu nuevo SearchDelegate

class PantallaBuscar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // appbar que tiene el titulo de la pantalla y el botonpara buscar
        title: Text('Buscar Productos'),
        backgroundColor: Color.fromARGB(255, 234, 210, 250),
        actions: [
          IconButton(
            icon: Icon(Icons.search), // lupa
            onPressed: () {
              showSearch( // funcion que muestra la pantalla cuando oprimes el icon button de buscar
                context: context,
                delegate: TiendaBuscar(), // esta clase va a manejar la busqueda de productos
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Ingresa el producto a buscar'),
      ),
    );
  }
}
