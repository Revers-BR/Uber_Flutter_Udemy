import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uber_flutter_udemy/config/firebase_options.dart';
import 'package:uber_flutter_udemy/config/rotas.dart';
import 'package:uber_flutter_udemy/config/tema.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final options = DefaultFirebaseOptions.currentPlatform;

  await Firebase.initializeApp(
    options: options,
  );
  
  runApp(
    MaterialApp(
      initialRoute: "/login",
      onGenerateRoute: Rotas.gerarRotas,
      theme: temaPadrao
    )
  );
}
