import 'package:catalogo/pantallas/tiendas/detallesTienda.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../clases/tienda.dart';
import 'dart:async';
import 'package:vector_math/vector_math_64.dart' as vector_math;

class ImagenInteractiva extends StatefulWidget {
  const ImagenInteractiva({super.key});

  @override
  State<ImagenInteractiva> createState() => _ImagenInteractivaState();
}

class _ImagenInteractivaState extends State<ImagenInteractiva> {
  final List<Tienda> _tiendas = [];
  // controlador para el widget interactiveviewer
  // usado para obtener las coordenadas originales cuando se hace zoom en la imagen
  final TransformationController _transformationController = TransformationController();
  // https://api.flutter.dev/flutter/widgets/InteractiveViewer/transformationController.html
  final GlobalKey _gestureKey = GlobalKey(); // atributo para obtener la posicion del mapa donde se toco exactamente

  // donde se va a dibujar cada iconbutton
  final Map<String, Offset> _posiciones = {
    'tienda_01': Offset(0.61, 0.54),
    'tienda_02': Offset(0.61, 0.54), // frente al a3
    'tienda_03': Offset(0.63, 0.45),
    'tienda_04': Offset(0.63, 0.45),
    'tienda_05': Offset(0.63, 0.45),
    'tienda_06': Offset(0.63, 0.45), // atras del a2
    'tienda_07': Offset(0.51, 0.40),
    'tienda_08': Offset(0.51, 0.40),
    'tienda_09': Offset(0.45, 0.34),
    'tienda_10': Offset(0.45, 0.34), // al costado del l3
    'tienda_11': Offset(0.59, 0.37),
    'tienda_12': Offset(0.59, 0.37),
    'tienda_13': Offset(0.59, 0.37),
    'tienda_14': Offset(0.59, 0.37), // al frente del a5
    'tienda_15': Offset(0.59, 0.28),
    'tienda_16': Offset(0.59, 0.28),
    'tienda_17': Offset(0.26, 0.28),
    'tienda_18': Offset(0.26, 0.28), // al frente del gimnasio
  };

  @override
  void initState() {  // cuando este widget se crea consultamos en firestore las tiendas
    super.initState();
    _cargarTiendas(); // con este metodo realizamos la consulta
  }
  // func asinc para cargar las tiendas desde firestone
  Future<void> _cargarTiendas() async {
    final documentos = await FirebaseFirestore.instance.collection('tiendas').get();
    // traer todos los documentos de tiendas
    // // https://stackoverflow.com/questions/46611369/get-all-from-a-firestore-collection-in-flutter
    final tiendas = documentos.docs.map((doc) { // convertir documentos a objetos tienda
      final data = doc.data();
      final id = doc.id;
      final posicion = _posiciones[id];
      if (posicion == null) return null; // regresar un null para poder ignorar las tiendas sin posicion
      // y evitar que explote la aplicacion

      return Tienda( // por alguna razon si los documentos venian sin imagen url la app explotaba
        id: id, // entonces hay que poner valores por default para evitar nulos
        nombre: data['nombre'] ?? 'Sin nombre',
        imagenUrl: data['imagenUrl'] ?? '',
        x: posicion.dx,
        y: posicion.dy,
      );
    }).whereType<Tienda>().toList(); // aqui ignoramos las tiendas con pos null

    setState(() { // actualizar el estado del widget para agregar las tiendas
      _tiendas.clear();
      _tiendas.addAll(tiendas);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose(); // liberar los recursos del controlador del zoom
    super.dispose(); // porque despues de mucho tiempo la aplicacion epxlotaba
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // widget para la barra scroll
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GestureDetector( //
            key: _gestureKey, // ver el atributo declarado al inicio del arch
            onTapUp: (details) { // capturar la posicion en la que tocaron
              final RenderBox box = _gestureKey.currentContext!.findRenderObject() as RenderBox; // convertir cordenadas
              final Offset posLocal = box.globalToLocal(details.globalPosition);
              // esto porque necesitamos saber donde toco especificamente el usuario con respecto al widget y no a la pantalla
              // usar un iconbutton es mas sencillo pero lo intente 500 veces y no puedo hacer que la hitbox del boton sea mas pequeña
              // entonces queda un chiquero en el mapa y no puedes seleccionar bien las tiendas
              // https://api.flutter.dev/flutter/rendering/RenderBox/globalToLocal.html
              final Matrix4 matrix = _transformationController.value; // matriz atcual 4x4
              final Matrix4 inverseMatrix = Matrix4.inverted(matrix); // matriz anterior para cuando se haga el zoom
              final vector_math.Vector3 vector3 = vector_math.Vector3(posLocal.dx, posLocal.dy, 0);
              final vector_math.Vector3 untransformedVector = inverseMatrix.transform3(vector3);
              final Offset posArreglada = Offset(untransformedVector.x, untransformedVector.y); // regresar a un offeset para trabajar con el

              _handleTap(posArreglada, box.size); // recibir la posicion ya transformada para elegir si el usario toco o no
            },
            child: InteractiveViewer(
              // sin el tranformation controller la app no reconocia los toques al hacer el zoom con el widget este
              // entonces hay que usar el tranformation controller para obtener la matriz transformacion de los movimientos con zoom
              // y transformar esas posiciones a lo que serian las posiciones originales (sin zoom)
              // y saber si toco o no una tiendita
              // me atore con esto pero la solucion la encntre en: https://medium.com/@millienakiganda/interactive-viewer-widget-in-flutter-2574ebc4a1b9
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(50),
              minScale: 0.85,
              maxScale: 4.0,
              child: AspectRatio(
                aspectRatio: 2004 / 1597,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration( // contenedor para el borde negro
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'lib/recursos/mapaAragon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: MapaPainter(tiendas: _tiendas),
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tiendas en el mapa',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListView.builder( // lista de las tiendas
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tiendas.length,
            itemBuilder: (context, index) {
              final tienda = _tiendas[index];
              return ListTile(
                title: Text(tienda.nombre),
                leading: const Icon(Icons.store),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TiendaDetalle(tienda: tienda), // movernos a su pantalla de detalles
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
// funcion que recibe la posicion transformada
  void _handleTap(Offset posLocal, Size size) {
    const hitboxToque = 15.0;

    final Map<Offset, List<Tienda>> agrupadas = {};// arreglo de las tiendas en la misma posicion
    // convertir las cordenadas offset en pixeles
    for (var tienda in _tiendas) {
      final pos = Offset(tienda.x * size.width, tienda.y * size.height);
      agrupadas.putIfAbsent(pos, () => []).add(tienda); // poner tienditas que estan juntas en el arreglo
    }

    for (final entry in agrupadas.entries) { // recorrer todas las tiendas
      final iconCenter = entry.key;
      if ((posLocal - iconCenter).distance <= hitboxToque) { // si el toque fue dentro de la hitbox mostamos el shodialog
        _mostrarDialogoT(entry.value);
        return;
      }
    }
  }

  void _mostrarDialogoT(List<Tienda> tiendas) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog( // alert dialog con todas las tiendas de agrupadas
        title: const Text('Tiendas en este edificio'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder( // lista de las tiendas
            shrinkWrap: true,
            itemCount: tiendas.length,
            itemBuilder: (context, index) {
              final tienda = tiendas[index];
              return ListTile(
                title: Text(tienda.nombre),
                leading: const Icon(Icons.store),
                onTap: () { // mover a detallestienda
                  Navigator.pop(context);
                  Navigator.push(
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
  }
}
// clase para dibujar los iconos d elas tiendas porque usando un
// stack e iconbuttons no jalaba esta cosa
class MapaPainter extends CustomPainter {
  final List<Tienda> tiendas;
  final double iconSize = 20.0;

  MapaPainter({required this.tiendas});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.red // color a llenar el circ
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint() // borde alrededor del circ
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Map<Offset, List<Tienda>> agrupadas = {}; // jalar las tiendas agrupadas para no pitar 2 veces el circulo
                                                    // ya me paso
    for (var tienda in tiendas) { // convertir offset a pixeles
      final pos = Offset(tienda.x * size.width, tienda.y * size.height);
      agrupadas.putIfAbsent(pos, () => []).add(tienda);
    }

    for (final entry in agrupadas.entries) { // dibujar el circulo rojo para cada agrupada (grupo de tienditas)
      final offset = entry.key;
      canvas.drawCircle(offset, iconSize / 2, paint);   // circ
      canvas.drawCircle(offset, iconSize / 2, borderPaint); // margen

      if (entry.value.length > 1) { // si hay mas de una tienda
        final textPainter = TextPainter( // dibujar con un text painter
          text: TextSpan(
            text: entry.value.length.toString(), // el numero de tiendas agrupadas
            style: TextStyle(
              color: Colors.white,
              fontSize: iconSize * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint( // dib texto
          canvas,
          offset - Offset(textPainter.width / 2, textPainter.height / 2), // centrar el texto a dib
        );
      }
    }
  }

  @override // sin esto explotaba el custom painter
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; // redibuja si hay cambios
}
