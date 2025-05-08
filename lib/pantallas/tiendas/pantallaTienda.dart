import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clases/tienda.dart';
import '../../widgets/tarjetaTienda.dart';
import 'detallesTienda.dart';

// widget para la segunda pantalla de la app (tiendas)
class SegundaPantalla extends StatefulWidget {
  @override
  _SegundaPantallaState createState() => _SegundaPantallaState();
}
// logica de la 2da pantalla
class _SegundaPantallaState extends State<SegundaPantalla> {
  // funcion asincrona para traer las tiendas de firestone
  Future<List<Tienda>> obtenerTiendas() async {
    // jalar la coleccion tiendas
    final snapshot = await FirebaseFirestore.instance.collection('tiendas').get();
    // convertirlos a la clase tienda que creamos, buscar tienda.dart para ver atributos
    return snapshot.docs.map((doc) => Tienda.fromFirestore(doc.id, doc.data())).toList();
  }
  // crear interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tiendas')), // barra superior
      body: FutureBuilder<List<Tienda>>(
        future: obtenerTiendas(), // obtener tiendas
        builder: (context, snapshot) {
          // rueda de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) { // viendo errores porque no sirve y me estoy volviendo loco
            print("Error al cargar las tiendas: ${snapshot.error}"); // imprimiendo en consola
            return Center(child: Text('Error al cargar las tiendas'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay tiendas disponibles'));
          } // cuando agreguen un documento a una coleccion verificar que los campos sean correctos porque por eso no cargaban las tiendas

          final tiendas = snapshot.data!; // mostrar en el widget grid

          return Padding(
            padding: EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: tiendas.length, // numero de tiendas
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //columnas
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (context, index) { // actual
                final tienda = tiendas[index];
                return TiendaCard( // regresar nuestro widget especial
                  tienda: tienda,
                  onTap: () {
                    Navigator.push( // movernos a la pantalla al oprimirla
                      context,
                      MaterialPageRoute(
                        builder: (_) => TiendaDetalleScreen(tienda: tienda),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
