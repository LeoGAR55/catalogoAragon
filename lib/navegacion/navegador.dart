import 'package:flutter/material.dart';
import 'package:catalogo/pantallas/mapa.dart';  // Asegúrate de que FirstScreen esté correctamente definida
import 'package:catalogo/pantallas/tiendas/segundaPantalla.dart';
import 'package:catalogo/pantallas/buscar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> { // widget main screen para navegar entre pantallas
  int _currentIndex = 0;  // Indice inicial
  final List<Widget> _screens = [
    PrimerPantalla(),  // Asegúrate de que FirstScreen esté bien importada
    SegundaPantalla(), // Asegúrate de que SecondScreen esté bien importada
    TerceraPantalla(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],  // Cargar la pantalla correspondiente al indice
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,  // El índice actual para cambiar la pantalla
        onTap: (index) { // cuando el usuario toca un icono cambiamos el indice
          setState(() { // actualizamos el estado para mostrar la pantalla
            _currentIndex = index;  // Cambiar el índice al hacer clic en un ítem
          });
        },
        items: [ // botones de la app con los cuales vamos a navegar entre pantallas
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.add_business), label: "Tiendas"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
        ],
      ),
    );
  }
}
