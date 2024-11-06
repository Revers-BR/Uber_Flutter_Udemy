import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_flutter_udemy/model/destino.dart';

class PainelPassageiro extends StatefulWidget {

  const PainelPassageiro({super.key});

  @override
  State<PainelPassageiro> createState() => _PainelPassageiro();
}

class _PainelPassageiro extends State<PainelPassageiro> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Set<Marker> _marcadores = {};

  final List<String> _itensMenu = [
    "Configurações","Deslogar"
  ];

  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();

  final TextEditingController _destinoController = TextEditingController(text: "Estrada do rufino, 937");

  LocationPermission _locationPermission = LocationPermission.denied;

  CameraPosition _cameraPosition = const CameraPosition(
          target: LatLng(-23.711993111425905, -46.6249616576713),
          zoom: 16
  );

  void _selectionarMenu(String itemSelecionado){

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

        _exibirMarcadores(position);

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

  void _movimentarCameraPosicao(CameraPosition cameraPosition){
    
    _googleMapController.future.then((googleMapController){
      googleMapController.moveCamera(
        CameraUpdate.newCameraPosition(cameraPosition)
      );
    });
  }

  void _addListenerPosicao(){

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((position) {

      final latitude = position.latitude;
      final longitude = position.longitude;

      _exibirMarcadores(position);

      setState(() {
        _cameraPosition = CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 18
        );

        _movimentarCameraPosicao(_cameraPosition);
      });
    });
  }

  void _checkPermission() async {

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if(!serviceEnabled)return Future.error("Serviço de localização desativado!");

    _locationPermission = await Geolocator.checkPermission();

    if(_locationPermission == LocationPermission.deniedForever)return Future.error("Permissão de localização está sempre negado, não iremos requisitar permissão novamente!"); 

    if(_locationPermission == LocationPermission.denied){

      _locationPermission = await Geolocator.requestPermission();

      if(_locationPermission == LocationPermission.denied)return Future.error("Permissao de localização foi negado!");
    }
  }

  void _exibirMarcadores(Position position){

    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final ImageConfiguration configuration = ImageConfiguration(
      devicePixelRatio: devicePixelRatio
    );

    const assetName = "imagens/passageiro.png";
    
    // ignore: deprecated_member_use
    BitmapDescriptor.fromAssetImage(configuration, assetName).then((icon){
      final latitude = position.latitude;
      final longitude = position.longitude;

      final Marker marcadorPassageiro = Marker(
        markerId: const MarkerId("marcador-passageiro"),
        position: LatLng(latitude, longitude), 
        infoWindow: const InfoWindow(title: "meu local"),
        icon: icon
      );

      _marcadores.add(marcadorPassageiro);
    });
  }

  void _chamarUber() async {

    final String enderecoDestino = _destinoController.text;

    if(enderecoDestino.isNotEmpty){

      final listaLocalizacao = await locationFromAddress(enderecoDestino);

      if(listaLocalizacao.isNotEmpty){
        final localizacao = listaLocalizacao[0];

        final latitude = localizacao.latitude;
        final longitude = localizacao.longitude;

        final listaEndereco = await placemarkFromCoordinates(latitude, longitude);

        if(listaEndereco.isNotEmpty){
          final endereco = listaEndereco[0];

          final cidade = endereco.administrativeArea;
          final cep = endereco.postalCode;
          final bairro = endereco.subLocality;
          final rua = endereco.thoroughfare;
          final numero = endereco.subThoroughfare;

          final ModelDestino destino = ModelDestino(
            cidade: cidade, 
            cep: cep, 
            bairro: bairro, 
            rua: rua, 
            numero: numero, 
            latitude: latitude, 
            longitude: longitude
          );

          String enderecoConfirmacao = "cidade : $cidade \n";
          enderecoConfirmacao += "cep : $cep \n";
          enderecoConfirmacao += "bairro : $bairro \n";
          enderecoConfirmacao += "rua : $rua \n";
          enderecoConfirmacao += "numero : $numero \n";

          if(mounted){
            showDialog(
              context: context, 
              builder: (context){
                return AlertDialog(
                  title: const Text("Confirma endereço?"),
                  content: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(enderecoConfirmacao),
                  ),
                  actions: [
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red)
                      ),
                      onPressed: () => Navigator.pop(context), 
                      child: const Text("Cancelar")
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context), 
                      child: const Text("Confirmar")
                    ),
                  ],
                );
              }
            );
          }
        }
      }
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
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _googleMapController.complete( controller ),
            initialCameraPosition: _cameraPosition,
            //myLocationEnabled: true,
            markers: _marcadores,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white
                ),
                child: const TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.location_on, color: Colors.grey),
                    contentPadding: EdgeInsets.fromLTRB(32,12,32,0),
                    hintText: "Meu local",
                    border: InputBorder.none,
                  ),
                ),
              )
            )
          ),

          Positioned(
            left: 0,
            right: 0,
            top: 55,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white
                ),
                child: TextField(
                  controller: _destinoController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.local_taxi, color: Colors.black),
                    contentPadding: EdgeInsets.fromLTRB(32,12,32,0),
                    hintText: "Digite o destino",
                    border: InputBorder.none,
                  ),
                ),
              )
            )
          ), 
        
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _chamarUber, 
                child: const Text("Chamar Uber")
              ),
            )
          )
        ],
      ), 
    );
  }
}