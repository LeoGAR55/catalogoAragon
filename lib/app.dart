import 'package:flutter/material.dart';
import 'widgets/navegador.dart'; // aqui debe estar mainscreen
import 'pantallas/tiendas/pantallaTienda.dart';

class MyApp extends StatelessWidget { // widget principal
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // ruta inicial de la app

      routes: {
        '/': (context) => MainScreen(),
        '/tienda': (context) { // https://api.flutter.dev/flutter/widgets/BuildContext-class.html
          // context nos permite pasar la informacion de como esta un widget con respecto a otro
          // para pantalla tienda tenemos que pasar la informacion de id y tienda para
          // saber que tienda se tiene que mostrar
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>; // el context espera el mapa cpn id y nombre
          return PantallaTienda(
            idTienda: args['id'],
            nombreTienda: args['nombre'],
          );
        },
      },
    );
  }
}
