import 'package:flutter/material.dart';
import 'package:uber_flutter_udemy/telas/login.dart';

void main() {
  runApp(
    MaterialApp(
      home: const Login(),
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const MaterialStatePropertyAll(Colors.white),
            backgroundColor: MaterialStatePropertyAll(Colors.blue[300])
          )
        )
      ),
    )
  );
}
