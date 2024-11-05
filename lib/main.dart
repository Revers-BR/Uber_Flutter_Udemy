import 'package:flutter/material.dart';
import 'package:uber_flutter_udemy/config/rotas.dart';
import 'package:uber_flutter_udemy/config/tema.dart';

void main() {
  runApp(
    MaterialApp(
      initialRoute: "/login",
      onGenerateRoute: Rotas.gerarRotas,
      theme: temaPadrao
    )
  );
}
