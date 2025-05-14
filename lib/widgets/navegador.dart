import 'package:flutter/material.dart';
import 'package:catalogo/pantallas/pantallaMapa.dart';  // importar las pantallas que usamos en la bottomnavbar
import 'package:catalogo/pantallas/tiendas/pantallaTienda.dart';
import 'package:catalogo/pantallas/pantallaBuscar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> { // widget main screen para navegar entre pantallas
  int _currentIndex = 0;  // indice inicial
  final List<Widget> _screens = [
    PantallaMapa(),  // constructores de nuestras pantallas
    PantallaTienda(),
    PantallaBuscar(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],  // Cargar la pantalla correspondiente al indice
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 234, 210, 250),
        currentIndex: _currentIndex,  // ind actual
        onTap: (index) { // cuando el usuario toca un icono cambiamos el indice
          setState(() { // actualizamos el estado para mostrar la pantalla
            _currentIndex = index;  // cambiar el índice al hacer clic en un ítem
          });
        },
        items: [ // botones de la app con los cuales vamos a navegar entre pantallas
          BottomNavigationBarItem(icon: Icon(Icons.account_tree_rounded), label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.add_business), label: "Tiendas"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
        ],
      ),
    );
  }
}
