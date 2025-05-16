import 'package:flutter/material.dart';
import 'package:catalogo/widgets/imagenInteractiva.dart'; // Asegúrate de crear este archivo con el widget

class PantallaMapa extends StatelessWidget {
  const PantallaMapa({super.key}); // cosntructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa de las tiendas en la FES Aragón"),
      backgroundColor: Color.fromARGB(255, 234, 210, 250),
        actions: [ // widget para mostrar el icono transparente a la derecha de la appbar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('lib/recursos/iconoTrans.png'),
          ),
        ],

      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ImagenInteractiva(), // widget personalizado del mapa

      ),
    );
  }
}
