import 'package:flutter/material.dart';

class PainelPassageiro extends StatefulWidget {

  const PainelPassageiro({super.key});

  @override
  State<PainelPassageiro> createState() => _PainelPassageiro();
}

class _PainelPassageiro extends State<PainelPassageiro> {

  @override
  Widget build ( BuildContext context ) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Passageiro"),
      ),
    );
  }
}