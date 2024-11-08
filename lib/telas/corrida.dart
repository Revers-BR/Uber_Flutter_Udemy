import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_flutter_udemy/model/requisicao_ativa.dart';
import 'package:uber_flutter_udemy/util/status_requisicao.dart';
import 'package:uber_flutter_udemy/util/usuario_firebase.dart';

class Corrida extends StatefulWidget {

  final String idRequisicao;

  const Corrida({super.key, required this.idRequisicao});

  @override
  State<Corrida> createState() => _Corrida();
}

class _Corrida extends State<Corrida> {

  final Set<Marker> _marcadores = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();

  LocationPermission _locationPermission = LocationPermission.denied;

  Position? _localPosicaoMotorista;

  Map<String, dynamic> _dadosRequisicao = {};

  CameraPosition _cameraPosition = const CameraPosition(
          target: LatLng(-23.711993111425905, -46.6249616576713),
          zoom: 16
  );

  String _textoBotao = "Aceitar corrida";
  Function? _funcaoBotao;
  Color? _corBotao = Colors.blue[300];

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

    const assetName = "imagens/motorista.png";
    
    // ignore: deprecated_member_use
    BitmapDescriptor.fromAssetImage(configuration, assetName).then((icon){
      final latitude = position.latitude;
      final longitude = position.longitude;

      final Marker marcadorPassageiro = Marker(
        markerId: const MarkerId("marcador-motorista"),
        position: LatLng(latitude, longitude), 
        infoWindow: const InfoWindow(title: "meu local"),
        icon: icon
      );

      _marcadores.add(marcadorPassageiro);
    });
  }

  void _movimentarCameraPosicao(CameraPosition cameraPosition){
    
    _googleMapController.future.then((googleMapController){
      googleMapController.moveCamera(
        CameraUpdate.newCameraPosition(cameraPosition)
      );
    });
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

          _localPosicaoMotorista = position;

          _movimentarCameraPosicao(_cameraPosition);
        });
      }
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

        _localPosicaoMotorista = position;
      });
    });
  }

  void _adicionarListenerRequisicao(){

    final String idRequisicao = _dadosRequisicao["id"];

    _firestore.collection("Requisicoes")
      .doc(idRequisicao)
      .snapshots()
      .listen((documento) {

        if(documento.data() != null){

          final Map<String, dynamic> dados = documento.data()!;

          final String status = dados["status"];

          switch (status) {
            case StatusRequisicao.aguardando:
              _statusAguardando();
              break;
            case StatusRequisicao.aCaminho:
              _statusACaminho();
              break;
          } 
        }
      });
  }

  void _alterarBotaoPrincipal(String texto, Color cor, Function? funcao){

    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });
  }

  void _statusAguardando(){

    _alterarBotaoPrincipal(
      "Aceitar corrida", 
      Colors.blue[300]!,
      _aceitarCorrida,
    );
  }

  void _statusACaminho(){

    _alterarBotaoPrincipal(
      "A caminho do passageiro", 
      Colors.grey,
      null,
    );
  }

  void _aceitarCorrida(){

    //Recuperar dados do motorista
    UsuarioFirebase.getDadosUsuario()
      .then((motorista){

        motorista.latitude = _localPosicaoMotorista!.latitude;
        motorista.longitude = _localPosicaoMotorista!.longitude;

        final String idRequisicao = _dadosRequisicao["id"];

        _firestore.collection("Requisicoes")
          .doc(idRequisicao)
          .update({
            "motorista" : motorista.toMap(),
            "status"    : StatusRequisicao.aCaminho,
          }).then((_){

            //Atualiza requisicao ativa

            final String idPassageiro = _dadosRequisicao["passageiro"]["id"];

            _firestore.collection("requisicao_ativa")
              .doc(idPassageiro)
              .update({
                "status": StatusRequisicao.aCaminho
              });

            //Salvar requisicao ativa para motorista

            final RequisicaoAtiva requisicaoAtivaMotorista = RequisicaoAtiva(
              idRequisicao: idRequisicao, 
              idUsuario   : motorista.idUsuario!, 
              status      : StatusRequisicao.aCaminho
            );

            _firestore.collection("requisicao_ativa_motorista")
              .doc(idRequisicao)
              .set(requisicaoAtivaMotorista.toMap());
          });
      });
  }

  void _recuperarRequisicao(){

    final idRequisicao = widget.idRequisicao;

    _firestore.collection("Requisicoes")
      .doc(idRequisicao).get().then((documento){

        if(documento.data() != null){

          _dadosRequisicao = documento.data()!;

          _adicionarListenerRequisicao();
        }
      });
  }

  @override
  void initState() {
    super.initState();
    if(_locationPermission != LocationPermission.always){
      _checkPermission();
    }
     _recuperaUltimaLocalizacao();
     _addListenerPosicao();
     _recuperarRequisicao();
  }

  @override
  Widget build  (BuildContext context ) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Corrida"),
      ),
      
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _googleMapController.complete( controller ),
            initialCameraPosition: _cameraPosition,
            markers: _marcadores,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(_corBotao)
                ),
                onPressed: () => _funcaoBotao != null 
                  ? _funcaoBotao!() 
                  : (){}, 
                child: Text(_textoBotao)
              ),
            )
          )
        ],
      ),  
    );
  }
}