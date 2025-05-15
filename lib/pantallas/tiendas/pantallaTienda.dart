import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clases/tienda.dart'; // tienda trae los datos que se bajan de firestore
import '../../widgets/tarjetaTienda.dart';
import 'detallesTienda.dart';

// widget para la segunda pantalla de la app (tiendas)
class PantallaTienda extends StatefulWidget { // stateful porque puede cambiarse
  final String? idTienda; // a veces estas variables vienen inicializadas como null desde otra pantalla
  final String? nombreTienda; // por eso use el "?", para que no implosione la appp si vienen como nulls

  const PantallaTienda({this.idTienda, this.nombreTienda}); // constructor
  @override
  _PantallaTiendaState createState() => _PantallaTiendaState();
}

// logica de la 2da pantalla
class _PantallaTiendaState extends State<PantallaTienda> {
  // funcion asincrona para traer las tiendas de firestone
  Future<List<Tienda>> obtenerTiendas() async {
    // usamos el idTienda que pasamos en los contextos anteriores como en el mapa
    // si no es nula quiere decir que la invocaron desde el mapa entonces solo necesitamos mostrar esa tienda
    if (widget.idTienda != null) {
      // buscar tienda específica
      final documento = await FirebaseFirestore.instance.collection('tiendas').doc(widget.idTienda).get();
      /*
        en firebase vamos a acceder al documento de la coleccion de tiendas usando el id del map en
        el widget de imginteractiva, estos tienen que coincidir y tienen el formato tienda_01,tienda_02,tienda_03
      */
      if (documento.exists) {
        return [Tienda.fromMap(documento.id, documento.data()!)]; // si existe lo convertimos a nuestra clase tienda
        //ver clase tienda para ver como se maneja la conversion
      } else {
        return []; // si la tienda no existe
      }
    }
    // si no se mando un idTienda especifico entonces estan entrando por la pantalla de tiendas
    // hay que traerlas todas con get
    final snapshot = await FirebaseFirestore.instance.collection('tiendas').get();

    // convertimos los datos de firestone a objetos tienda de nuevo
    return snapshot.docs.map((doc) => Tienda.fromMap(doc.id, doc.data())).toList();
  }


  // crear interfaz
  @override
  Widget build(BuildContext context) { // build construye los widgets que se van a usar
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombreTienda ?? 'Tiendas'), // barra superior, mostrar nombre si viene del mapa
        backgroundColor: Color.fromARGB(255, 234, 210, 250),
        actions: [ // widget para mostrar el icono transparente a la derecha de la appbar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('lib/recursos/iconoTrans.png'),
          ),
        ],
      ),
      body: FutureBuilder<List<Tienda>>( // widget para definir que se va a mostrar mientras no se haya obtenido los datos
        // y que se va a mostrar cuando ya se obtengan
        //https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html
        future: obtenerTiendas(), // obtener tiendas
        builder: (context, snapshot) {
          // rueda de carga
          if (snapshot.connectionState == ConnectionState.waiting) { // mientras se esten cargando los datos
            return Center(child: CircularProgressIndicator()); // mostramos un circ de carga
          } else if (snapshot.hasError) { // viendo errores porque no sirve y me estoy volviendo loco
            print("Error al cargar las tiendas: ${snapshot.error}"); // imprimiendo en consola
            return Center(child: Text('Error al cargar las tiendas')); // mi coleccion estaba mal y por eso no se cargaban los datos
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay tiendas disponibles'));
          } // cuando agreguen un documento a una coleccion verificar que los campos sean correctos porque por eso no cargaban las tiendas

          final tiendas = snapshot.data!; // mostrar en el widget grid

          return Padding(
            padding: EdgeInsets.all(8.0),
            // widget que sirve como rejilla para las tarjetaTienda
            child: GridView.builder( // https://www.youtube.com/watch?v=2W3pjkPXOSA - Using Gridview in Flutter to Create a Products Grid List - 15 - Flutter Ecommerce App With Firebase
              itemCount: tiendas.length, // numero de tiendas(19)
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //columnas
                crossAxisSpacing: 8, // espacio entre tarjetasa
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) { // actual, hacemos una celda para cada tienda
                final tienda = tiendas[index];
                return TarjetaTienda( // regresar nuestro widget
                  tienda: tienda, // para cada tienda cramos una tienda
                  onTap: () {
                    if (tienda != null) {  // debug porque habia puesto las cordenadas como required y mis tiendas estaban apareciendo nulas
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TiendaDetalle(tienda: tienda), // cuando el usuario haga click invocamos al builder de tiendadetalle para crarla y movernos
                        ),
                      );
                    } else {
                      print("la tienda es nula");
                    }
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
