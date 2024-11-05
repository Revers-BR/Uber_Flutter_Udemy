import 'package:flutter/material.dart';

class PainelMotorista extends StatefulWidget {

  const PainelMotorista({super.key});

  @override
  State<PainelMotorista> createState() => _PainelMotorista();
}

class _PainelMotorista extends State<PainelMotorista> {

  @override
  Widget build (BuildContext context ) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Motorista"),
      ),
    );
  }
}