import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PainelPassageiro extends StatefulWidget {

  const PainelPassageiro({super.key});

  @override
  State<PainelPassageiro> createState() => _PainelPassageiro();
}

class _PainelPassageiro extends State<PainelPassageiro> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> _itensMenu = [
    "Configurações","Deslogar"
  ];

  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();

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
  Widget build ( BuildContext context ) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Passageiro"),
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
      body: GoogleMap(
        onMapCreated: (controller) => _googleMapController.complete( controller ),
        initialCameraPosition: const CameraPosition(
          target: LatLng(-23.711993111425905, -46.6249616576713),
          zoom: 16
        )
      ),
    );
  }
}