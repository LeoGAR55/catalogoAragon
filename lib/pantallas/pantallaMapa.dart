import 'package:flutter/material.dart';

class PrimerPantalla extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<PrimerPantalla> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pantalla de bienvenida"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text("Bienvenido"),
      ),
    );
  }
}
