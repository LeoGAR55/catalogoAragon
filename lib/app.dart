import 'package:flutter/material.dart';
import 'widgets/navegador.dart';  // Asegúrate de que MainScreen esté allí

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),  // Pantalla principal de la app
    );
  }
}
