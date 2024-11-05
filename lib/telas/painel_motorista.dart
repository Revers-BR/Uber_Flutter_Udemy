import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PainelMotorista extends StatefulWidget {

  const PainelMotorista({super.key});

  @override
  State<PainelMotorista> createState() => _PainelMotorista();
}

class _PainelMotorista extends State<PainelMotorista> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> _itensMenu = [
    "Configurações","Deslogar"
  ];

  _selectionarMenu(String itemSelecionado){

    switch (itemSelecionado) {
      case "Configurações":
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
  }

  void _deslogarUsuario(){

    _auth.signOut().then(
      (_) => Navigator.pushNamedAndRemoveUntil(
        context, 
        "/login", 
        (route) => false
      )
    );
  }

  @override
  Widget build (BuildContext context ) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Motorista"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _selectionarMenu,
            itemBuilder: (_) {
              return _itensMenu.map((item){
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item)
                );
              }).toList();
            },
          )
        ],
      ),
    );
  }
}