import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  LocationPermission _locationPermission = LocationPermission.denied;

  CameraPosition _cameraPosition = const CameraPosition(
          target: LatLng(-23.711993111425905, -46.6249616576713),
          zoom: 16
  );

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

  void _recuperaUltimaLocalizacao(){

    Geolocator.getLastKnownPosition().then((position){
      
      if(position != null){

        final latitude = position.latitude;
        final longitude = position.longitude;

        setState(() {
          _cameraPosition = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 19
          );

          _movimentarCameraPosicao(_cameraPosition);
        });
      }
    });
  }

  _movimentarCameraPosicao(CameraPosition cameraPosition){
    
    _googleMapController.future.then((googleMapController){
      googleMapController.moveCamera(
        CameraUpdate.newCameraPosition(cameraPosition)
      );
    });
  }

  _addListenerPosicao(){

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((position) {

      final latitude = position.latitude;
      final longitude = position.longitude;

      setState(() {
        _cameraPosition = CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 18
        );

        _movimentarCameraPosicao(_cameraPosition);
      });
    });
  }

  _checkPermission() async {

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if(!serviceEnabled)return Future.error("Serviço de localização desativado!");

    _locationPermission = await Geolocator.checkPermission();

    if(_locationPermission == LocationPermission.deniedForever)return Future.error("Permissão de localização está sempre negado, não iremos requisitar permissão novamente!"); 

    if(_locationPermission == LocationPermission.denied){

      _locationPermission = await Geolocator.requestPermission();

      if(_locationPermission == LocationPermission.denied)return Future.error("Permissao de localização foi negado!");
    }
  }

  @override
  void initState() {
    super.initState();
    if(_locationPermission != LocationPermission.always){
      _checkPermission();
    }
     _recuperaUltimaLocalizacao();
     _addListenerPosicao();
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
        initialCameraPosition: _cameraPosition,
        myLocationEnabled: true,
      ),
    );
  }
}