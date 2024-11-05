import 'package:flutter/material.dart';

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