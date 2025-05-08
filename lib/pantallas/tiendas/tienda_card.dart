import 'package:flutter/material.dart';
import 'tienda.dart';
// widget para mostrar la tienda como una tarjeta en segunda pantalla
class TiendaCard extends StatelessWidget {
  final Tienda tienda;
  final VoidCallback onTap; // en toque
  const TiendaCard({required this.tienda, required this.onTap}); // constructor
  // interfaz
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          children: [ // la tarjeta solo tiene la imagen y el nombre de la tienda
            Expanded(
              child: Image.network(
                tienda.imagenUrl, // url de firebase
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (context, child, loadingProgress) { // rueda de carga
                  if (loadingProgress == null) return child;
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
