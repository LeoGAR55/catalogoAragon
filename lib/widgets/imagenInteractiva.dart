import 'package:catalogo/pantallas/tiendas/detallesTienda.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/tienda.dart';

class ImagenInteractiva extends StatefulWidget {
  const ImagenInteractiva({super.key});

  @override
  State<ImagenInteractiva> createState() => _ImagenInteractivaState();
}

class _ImagenInteractivaState extends State<ImagenInteractiva> {
  List<Tienda> _tiendas = []; // todas las tiendas

  final Map<String, Offset> _posiciones = { // donde se va a dibujar cada iconbutton
    'tienda_01': Offset(0.55, 0.47),
    'tienda_02': Offset(0.55, 0.47), // frente al a3
    'tienda_03': Offset(0.59, 0.41),
    'tienda_04': Offset(0.59, 0.41),
    'tienda_05': Offset(0.59, 0.41),
    'tienda_06': Offset(0.59, 0.41), // atras del a2
    'tienda_07': Offset(0.46, 0.36),
    'tienda_08': Offset(0.46, 0.36), // entre el a4 y a5
    'tienda_09': Offset(0.4, 0.31),
    'tienda_10': Offset(0.4, 0.31), // al costado del l3
    'tienda_11': Offset(0.5, 0.23),
    'tienda_12': Offset(0.5, 0.23),
    'tienda_13': Offset(0.5, 0.23),
    'tienda_14': Offset(0.5, 0.23), // al frente del a5
    'tienda_15': Offset(0.56, 0.26),
    'tienda_16': Offset(0.56, 0.26), // enfrente del a12 y a6
    'tienda_17': Offset(0.214, 0.247),
    'tienda_18': Offset(0.214, 0.247), // al frente del gimnasio
    'tienda_19': Offset(0.494, 0.32), // colectivo en el a6
  };

  @override // cuando este widget se crea consultamos en firestore las tiendas
  void initState() {
    super.initState();
    _cargarTiendas(); // con este metodo realizamos la consulta
  }

  Future<void> _cargarTiendas() async {
    final documentos = await FirebaseFirestore.instance.collection('tiendas').get(); // traer todos los documentos de tiendas
    // https://stackoverflow.com/questions/46611369/get-all-from-a-firestore-collection-in-flutter
    final tiendas = documentos.docs.map((doc) { // convertir documentos a objetos tienda
      final data = doc.data();
      final id = doc.id;
      final posicion = _posiciones[id] ?? Offset(0.01, 0.01); // posiciones default
      return Tienda( // por alguna razon si los documentos venian sin imagen url la app explotaba
        id: id, // entonces hay que poner valores por default para evitar nulos
        nombre: data['nombre'] ?? 'Sin nombre',
        imagenUrl: data['imagenUrl'] ?? '',
        cordx: posicion.dx,
        cordy: posicion.dy,
      );
    }).toList();

    setState(() { // volver a dibujar el widget con las nuevas tiendas cargadas
      _tiendas = tiendas;
    });
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
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(50), // deslizazmiento fuera de la imagen en pixeles
            minScale: 0.85, // minimos y maximos del zoom a la img
            maxScale: 4.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // AGRUPAR TIENDAS
                // muchas tiendas estan muy juntas y se veia muy mal el mapa con tantos iconos
                // entonces decidi agrupar las que tengan las mismas cordenadas
                // y mostrar un menu para seleccionar la que quisieras
                final Map<Offset, List<Tienda>> agrupadas = {};
                for (var tienda in _tiendas) {
                  final key = Offset(tienda.cordx, tienda.cordy);
                  agrupadas.putIfAbsent(key, () => []).add(tienda);
                }
                  // widget para poder poner los iconbuttons encima de la imagen
                // https://www.dhiwise.com/post/flutter-stack-your-ultimate-guide-to-overlapping-widgets
                return Stack(
                  children: [
                    Image.asset( // traer la imagen
                      'lib/recursos/mapaAragon.png',
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                    ),
                    ...agrupadas.entries.map((entry) { // dibujar iconbuttons
                      final left = entry.key.dx * constraints.maxWidth;
                      final top = entry.key.dy * constraints.maxHeight;
                      return Positioned(
                        left: left,
                        top: top,
                        child: IconButton(
                          icon: Icon(
                            // si hay mas de 1 icono en una posicion se usa el icono 1 y si solo hay 1 se usa el icono 2
                            // esto solo sirve en el caso del colectivo :3
                            entry.value.length > 1 ? Icons.storefront : Icons.store,
                            color: Colors.redAccent,
                            size: 24,
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
