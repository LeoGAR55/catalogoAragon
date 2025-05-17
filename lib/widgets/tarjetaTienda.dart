import 'package:flutter/material.dart';
import '../clases/tienda.dart';

// widget para mostrar la tienda como una tarjeta en la pantallaTienda
class TarjetaTienda extends StatelessWidget {
  final Tienda tienda; // objeto tienda con toda la informacion de firebase
  final VoidCallback onTap; // funcion para que el widget ejecute algo al tocarse
  // aqui lo usamos para que cuando toquemos la tarjeta llamemos al constructor de tiendaDetalle

  const TarjetaTienda({required this.tienda, required this.onTap}); // constructor

  // de este video viene la idea de meter el container dentro del gridview
  // https://www.youtube.com/watch?v=7HpvSpyMqjI
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(// para los bordes
          border: Border.all(color: Colors.grey, width: 2.0),
          borderRadius: BorderRadius.circular(2),
          color: Color.fromARGB(255, 234, 210, 250),
        ),
        child: Column(
          children: [ // la tarjeta solo tiene la imagen y el nombre de la tienda
            Expanded(
              child: Image.network(
                tienda.imagenUrl, // url de firebase
                fit: BoxFit.cover, // rellenar la tarjeta con la imagen
                loadingBuilder: (context, child, loadingProgress) { // rueda de carga en lo que se carga la imagen
                  if (loadingProgress == null) return child; // así viene el código en la doc oficial: https://api.flutter.dev/flutter/widgets/Image/loadingBuilder.html
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) { // por si no se llega a cargar la img correctamente
                  return Center(child: Icon(Icons.broken_image, size: 50));
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(tienda.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
