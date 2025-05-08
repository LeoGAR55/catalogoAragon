import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // buscar plugins de flutter
  await Firebase.initializeApp( // inicializar firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp()); // revisar app.dart para ver la funcion
}
