import 'package:catalogo/pantallas/tiendas/detallesTienda.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/tienda.dart';
import 'dart:async';

class ImagenInteractiva extends StatefulWidget {
  const ImagenInteractiva({super.key});

  @override
  State<ImagenInteractiva> createState() => _ImagenInteractivaState();
}

class _ImagenInteractivaState extends State<ImagenInteractiva> {
  final GlobalKey _imagenKey = GlobalKey(); // https://stackoverflow.com/questions/56895273/how-to-use-globalkey-to-maintain-widgets-states-when-changing-parents
  List<Tienda> _tiendas = []; // todas las tiendas
  // donde se va a dibujar cada iconbutton
  final Map<String, Offset> _posiciones = {
    'tienda_01': Offset(1187, 847),
    'tienda_02': Offset(1187, 847), // frente al a3
    'tienda_03': Offset(1222, 678),
    'tienda_04': Offset(1222, 678),
    'tienda_05': Offset(1222, 678),
    'tienda_06': Offset(1222, 678), // atras del a2
    'tienda_07': Offset(992, 622),
    'tienda_08': Offset(992, 622), // entre el a4 y a5
    'tienda_09': Offset(861, 511),
    'tienda_10': Offset(861, 511), // al costado del l3
    'tienda_11': Offset(1162, 535),
    'tienda_12': Offset(1162, 535),
    'tienda_13': Offset(1162, 535),
    'tienda_14': Offset(1162, 535), // al frente del a5
    'tienda_15': Offset(1112, 399),
    'tienda_16': Offset(1112, 399), // enfrente del a12 y a6
    'tienda_17': Offset(501, 394),
    'tienda_18': Offset(501, 394), // al frente del gimnasio
    'tienda_19': Offset(1002, 503), // colectivo en el a6
  };



  @override
  void initState() { // cuando este widget se crea consultamos en firestore las tiendas
    super.initState();
    _cargarTiendas(); // con este metodo realizamos la consulta
  }

  // func asinc para cargar las tiendas desde firestone
  Future<void> _cargarTiendas() async {
    final documentos = await FirebaseFirestore.instance.collection('tiendas').get(); // traer todos los documentos de tiendas
    // https://stackoverflow.com/questions/46611369/get-all-from-a-firestore-collection-in-flutter
    final tiendas = documentos.docs.map((doc) { // convertir documentos a objetos tienda
      final data = doc.data();
      final id = doc.id;
      // obtenemos las coordenadas y si no hay les ponemos un valor default para que no explote la app
      final x = (data['x'] ?? 0.0).toDouble();
      final y = (data['y'] ?? 0.0).toDouble();

      return Tienda( // por alguna razon si los documentos venian sin imagen url la app explotaba
        id: id, // entonces hay que poner valores por default para evitar nulos
        nombre: data['nombre'] ?? 'Sin nombre',
        imagenUrl: data['imagenUrl'] ?? '',
        x: x, // coord en pixeles de la clase tienda
        y: y,
      );
    }).toList();

    setState(() { // volver a dibujar el widget con las nuevas tiendas cargadas
      _tiendas = tiendas;
    });
  }

  // función para obtener el tamaño de la imagen
  // sin la func las tiendas se dibujaban bien en la computadora pero en el celular se moviam
  // porque las coordenadas no eran relativas
  // la función puede ser asincrona porque el proceso de carga de la imagen en flutter es asincrono
  // pero si sabemos el tamaño de la imagen podemos hardcodearlo y ya
  Size _tamanioImagen(BoxConstraints constraints) {
    const originalWidth = 2004.0;
    const originalHeight = 1597.0;

    // calculamos el ratio para escalar la imagen al ancho maximo permitido
    final ratio = constraints.maxWidth / originalWidth;
    double width = constraints.maxWidth;
    double height = originalHeight * ratio;

    // si la altura escalada es mayor al máximo permitido
    // volvemos a calcular
    if (height > constraints.maxHeight) {
      final newRatio = constraints.maxHeight / originalHeight;
      width = originalWidth * newRatio;
      height = constraints.maxHeight;
    }

    return Size(width, height);
  }

  // interfaz
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Container( // contenedor para hacer un borde alrededor del interactive viewer
          decoration: BoxDecoration( // porque la imagen es una png y no s eveia bien
            border: Border.all(color: Colors.grey, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {

              final imageSize = _tamanioImagen(constraints);
              final extraX = (constraints.maxWidth - imageSize.width) / 2;
              final extraY = (constraints.maxHeight - imageSize.height) / 2;

              // AGRUPAR TIENDAS
              // muchas tiendas estan muy juntas y se veia muy mal el mapa con tantos iconos
              // entonces decidi agrupar las que tengan las mismas cordenadas
              // y mostrar un menu para seleccionar la que quisieras
              final Map<Offset, List<Tienda>> agrupadas = {};
              for (var tienda in _tiendas) { // recorrer lista tiendas ya signar las cordenadas de posiciones
                final key = _posiciones[tienda.id] ?? Offset(0, 0);
                agrupadas.putIfAbsent(key, () => []).add(tienda);
              }

              return InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(50), // deslizazmiento fuera de la imagen en pixeles
                minScale: 0.85,  // minimos y maximos del zoom a la img
                maxScale: 4.0,
                // widget para poder poner los iconbuttons encima de la imagen
                // https://www.dhiwise.com/post/flutter-stack-your-ultimate-guide-to-overlapping-widgets
                child: Stack(
                  children: [
                    // Mapa base
                    Image.asset(
                      'lib/recursos/mapaAragon.png',
                      key: _imagenKey,
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),

                     // dibujar iconbuttons con las posiciones d elos pixeles
                    ...agrupadas.entries.map((entry) {
                      // transformar coordenadas en pixeles al tamaño de la pantalla donde se este mostrando
                      final left = entry.key.dx * (imageSize.width / 2004.0) + extraX;
                      final top = entry.key.dy * (imageSize.height / 1597.0) + extraY;

                      return Positioned(
                        left: left,
                        top: top,
                        child: IconButton(
                          padding: EdgeInsets.zero, // quitar el padding en los icon btn
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            // si hay mas de 1 icono en una posicion se usa el icono 1 y si solo hay 1 se usa el icono 2
                            // esto solo sirve en el caso del colectivo :3
                            entry.value.length > 1 ? Icons.storefront : Icons.store,
                            color: Colors.redAccent,
                            size: 12,
                          ),
                          onPressed: () {
                            // al presionar un icono mostramos un showdialog con las tiendas
                            // con coordenadas iguales (definidas en imginteractiva)
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Tiendas en este edificio'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: entry.value.length,
                                    itemBuilder: (context, index) {
                                      final tienda = entry.value[index];
                                      return ListTile(
                                        title: Text(tienda.nombre),
                                        leading: const Icon(Icons.store),
                                        // cuando se escoge una tienda en show dialog
                                        onTap: () {
                                          Navigator.pop(context); // cerrar showdialog
                                          Navigator.push( // ir a tiendadetalles
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => TiendaDetalle(tienda: tienda),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
