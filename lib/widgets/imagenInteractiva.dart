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
  List<Tienda> _tiendas = [];
  final TransformationController _transformationController = TransformationController();

  final Map<String, Offset> _posiciones = {
    'tienda_01': Offset(0.61, 0.54),
    'tienda_02': Offset(0.61, 0.54),
    'tienda_03': Offset(0.63, 0.45),
    'tienda_04': Offset(0.63, 0.45),
    'tienda_05': Offset(0.63, 0.45),
    'tienda_06': Offset(0.63, 0.45),
    'tienda_07': Offset(0.51, 0.40),
    'tienda_08': Offset(0.51, 0.40),
    'tienda_09': Offset(0.45, 0.34),
    'tienda_10': Offset(0.45, 0.34),
    'tienda_11': Offset(0.59, 0.37),
    'tienda_12': Offset(0.59, 0.37),
    'tienda_13': Offset(0.59, 0.37),
    'tienda_14': Offset(0.59, 0.37),
    'tienda_15': Offset(0.59, 0.28),
    'tienda_16': Offset(0.59, 0.28),
    'tienda_17': Offset(0.26, 0.28),
    'tienda_18': Offset(0.26, 0.28),
  };

  @override
  void initState() {
    super.initState();
    _cargarTiendas();
  }

  Future<void> _cargarTiendas() async {
    final documentos = await FirebaseFirestore.instance.collection('tiendas').get();
    final tiendas = documentos.docs.map((doc) {
      final data = doc.data();
      final id = doc.id;
      final posicion = _posiciones[id];
      if (posicion == null) return null;

      return Tienda(
        id: id,
        nombre: data['nombre'] ?? 'Sin nombre',
        imagenUrl: data['imagenUrl'] ?? '',
        x: posicion.dx,
        y: posicion.dy,
      );
    }).whereType<Tienda>().toList();

    setState(() {
      _tiendas = tiendas;
    });
  }

  Offset? _tapPosition;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(50),
        minScale: 0.85,
        maxScale: 4.0,
        child: GestureDetector(
          onTapUp: (details) {
            RenderBox box = context.findRenderObject() as RenderBox;
            Offset localPosition = box.globalToLocal(details.globalPosition);

            final Matrix4 matrix = _transformationController.value;
            final Matrix4 inverseMatrix = Matrix4.inverted(matrix);
            final vector_math.Vector3 vector3 = vector_math.Vector3(localPosition.dx, localPosition.dy, 0);
            final vector_math.Vector3 untransformedVector = inverseMatrix.transform3(vector3);
            final Offset untransformedPosition = Offset(untransformedVector.x, untransformedVector.y);

            _handleTap(untransformedPosition, box.size);
          },
          child: AspectRatio(
            aspectRatio: 2004 / 1597,
            child: Stack(
              children: [
                // Fondo con borde negro
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Imagen del mapa
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'lib/recursos/mapaAragon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Íconos de tiendas
                CustomPaint(
                  painter: MapaPainter(tiendas: _tiendas),
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _handleTap(Offset localPosition, Size size) {
    const tapRadius = 15.0;

    final Map<Offset, List<Tienda>> agrupadas = {};

    for (var tienda in _tiendas) {
      final pos = Offset(tienda.x * size.width, tienda.y * size.height);
      agrupadas.putIfAbsent(pos, () => []).add(tienda);
    }

    for (final entry in agrupadas.entries) {
      final iconCenter = entry.key;
      if ((localPosition - iconCenter).distance <= tapRadius) {
        _mostrarTiendasEnDialogo(entry.value);
        return;
      }
    }
  }

  void _mostrarTiendasEnDialogo(List<Tienda> tiendas) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tiendas en este edificio'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tiendas.length,
            itemBuilder: (context, index) {
              final tienda = tiendas[index];
              return ListTile(
                title: Text(tienda.nombre),
                leading: const Icon(Icons.store),
                onTap: () {
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

class MapaPainter extends CustomPainter {
  final List<Tienda> tiendas;
  final double iconSize = 20.0;

  MapaPainter({required this.tiendas});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.red;
    final Map<Offset, List<Tienda>> agrupadas = {};

    for (var tienda in tiendas) {
      final pos = Offset(tienda.x * size.width, tienda.y * size.height);
      agrupadas.putIfAbsent(pos, () => []).add(tienda);
    }

    for (final entry in agrupadas.entries) {
      final offset = entry.key;
      canvas.drawCircle(offset, iconSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

