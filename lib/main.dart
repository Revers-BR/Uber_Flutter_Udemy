import 'package:flutter/material.dart';
import 'package:uber_flutter_udemy/telas/login.dart';

final ThemeData temaPadrao = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xff546e7a),
    foregroundColor: Colors.white
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const MaterialStatePropertyAll(Colors.white),
      backgroundColor: MaterialStatePropertyAll(Colors.blue[300])
    )
  )
);

void main() {
  runApp(
    MaterialApp(
      home: const Login(),
      theme: temaPadrao
    )
  );
}
