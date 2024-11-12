import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_flutter_udemy/model/requisicao_ativa.dart';
import 'package:uber_flutter_udemy/util/marcador.dart';
import 'package:uber_flutter_udemy/util/status_requisicao.dart';
import 'package:uber_flutter_udemy/util/usuario_firebase.dart';

class Corrida extends StatefulWidget {

  final String idRequisicao;

  const Corrida({super.key, required this.idRequisicao});

  @override
  State<Corrida> createState() => _Corrida();
}

class _Corrida extends State<Corrida> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();

  LocationPermission _locationPermission = LocationPermission.denied;

  String _statusRequisicao = StatusRequisicao.aguardando;

  Position? _localMotorista;

  String? _idRequisicao;

  Set<Marker> _marcadores = {};

  String? _mensagemStatus;

  Map<String, dynamic> _dadosRequisicao = {};

  CameraPosition _cameraPosition = const CameraPosition(
          target: LatLng(-23.711993111425905, -46.6249616576713),
          zoom: 18
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

  void _movimentarCameraPosicao(CameraPosition cameraPosition){
    
    _googleMapController.future.then((googleMapController){
      googleMapController.moveCamera(
        CameraUpdate.newCameraPosition(cameraPosition)
      );
    });
  }

  void _movimentarCameraBounds(LatLng posicao1, LatLng posicao2){

    double sLat, nLat, sLon, nLon;

    if(posicao1.latitude <= posicao2.latitude){
      sLat = posicao1.latitude;
      nLat = posicao2.latitude;
    }else{
      sLat = posicao2.latitude;
      nLat = posicao1.latitude;
    }

    if(posicao1.longitude <= posicao2.longitude){
      sLon = posicao1.longitude;
      nLon = posicao2.longitude;
    }else{
      sLon = posicao2.longitude;
      nLon = posicao1.longitude;
    }

    LatLng southwest = LatLng( sLat, sLon);

    LatLng northeast = LatLng(nLat, nLon );

    LatLngBounds latLngBounds = LatLngBounds(
      southwest: southwest, 
      northeast: northeast
    );
    
    _googleMapController.future.then((googleMapController){
      googleMapController.moveCamera(
        CameraUpdate.newLatLngBounds(
          latLngBounds, 
          100
        )
      );
    });
  }

  void _recuperaUltimaLocalizacao(){

    Geolocator.getLastKnownPosition().then((position){
      
      if(position != null){

        //Atualizar localizacao em tempo real motorista
      }
    });
  }

  void _addListenerPosicao(){

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((position) {

      //Atualizar motorista em tempo real;
      if(_statusRequisicao != StatusRequisicao.aguardando){

        final idRequisicao = widget.idRequisicao;

        UsuarioFirebase.atulaizarDadosLocalizacao(
          idRequisicao, 
          LatLng(
            position.latitude, 
            position.longitude
          )
        );
      }else{
        setState(() => _localMotorista = position);

        _statusAguardando();
      }
    });
  }

  void _adicionarListenerRequisicao(){

    final idRequisicao = widget.idRequisicao;

    //final String idRequisicao = _dadosRequisicao["id"];

    _firestore.collection("Requisicoes")
      .doc(idRequisicao)
      .snapshots()
      .listen((documento) {

        if(documento.data() != null){

          _dadosRequisicao = documento.data()!;

          final Map<String, dynamic> dados = documento.data()!;

          _statusRequisicao = dados["status"];

          switch (_statusRequisicao) {
            case StatusRequisicao.aguardando:
              _statusAguardando();
              break;
            case StatusRequisicao.aCaminho:
              _statusACaminho();
              break;
            case StatusRequisicao.viagem:
             _statusEmViagem();
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

    if(_localMotorista != null){

      final double motoristaLat   = _localMotorista!.latitude;
      final double motoristaLong  = _localMotorista!.longitude;

      LatLng position = LatLng(
        motoristaLat,
        motoristaLong    
      );
      
      _criarMarcador(
        "motorista", 
        position,
        "meu local"
      ).then((marcador) => _marcadores.add(marcador));

      CameraPosition cameraPosition = CameraPosition(
        target: position,
        zoom: 18
      );

      _movimentarCameraPosicao(cameraPosition);
    }
  }
  
  Future<Marker> _criarMarcador(String icone, LatLng posicao, String titulo) async {
    
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final ImageConfiguration configuration = ImageConfiguration(
      devicePixelRatio: devicePixelRatio
    );

    final assetName = "imagens/$icone.png";
    
    // ignore: deprecated_member_use
    final icon = await BitmapDescriptor.fromAssetImage(configuration, assetName);
      
    final Marker marcador = Marker(
      markerId: MarkerId("marcador-$titulo"),
      position: posicao, 
      infoWindow: InfoWindow(title: titulo),
      icon: icon
    );

    return marcador;
  }

  void _exibirDoisMarcadores(Marcador marcador1, Marcador marcador2) async {

    final Set<Marker> marcadores = {};

    final m1 = await _criarMarcador(marcador1.icone, marcador1.localizcao, marcador1.titulo);

    final m2 = await _criarMarcador(marcador2.icone, marcador2.localizcao, marcador2.titulo);

    marcadores.addAll({ m1, m2 });

    setState(() => _marcadores = marcadores);
  }

  void _iniciarCorrida(){
    
    _firestore.collection("Requisicoes")
      .doc(_idRequisicao)
      .update({
        "origem": {
          "latitude": _dadosRequisicao["motorista"]["latitude"],
          "longitude": _dadosRequisicao["motorista"]["longitude"]
        },
        "status": StatusRequisicao.viagem
      });

      final String idPassageiro = _dadosRequisicao["passageiro"]["id"];

      _firestore.collection("requisicao_ativa")
      .doc(idPassageiro)
      .update({"status" : StatusRequisicao.viagem});

      final String idMotorista = _dadosRequisicao["motorista"]["id"];

      _firestore.collection("requisicao_ativa_motorista")
      .doc(idMotorista)
      .update({"status" : StatusRequisicao.viagem});
  }

  void _statusACaminho(){

    _mensagemStatus = "A caminho do passageiro";

    _alterarBotaoPrincipal(
      "Iniciar corrida", 
      Colors.grey,
      _iniciarCorrida,
    );

    LatLng posicaoPassageiro = LatLng(
      _dadosRequisicao["passageiro"]["latitude"], 
      _dadosRequisicao["passageiro"]["longitude"]
    );

    LatLng posicaoMotorista = LatLng(
      _dadosRequisicao["motorista"]["latitude"], 
      _dadosRequisicao["motorista"]["longitude"]
    );

    final Marcador marcador1 = Marcador("passageiro", posicaoPassageiro, "local Passageiro");

    final Marcador marcador2 = Marcador("motorista", posicaoMotorista, "local Motorista");

    _exibirDoisMarcadores(marcador1, marcador2);

    _movimentarCameraBounds(marcador1.localizcao, marcador2.localizcao);
  }

  _statusEmViagem(){
    _mensagemStatus = "Em viagem";

    _alterarBotaoPrincipal(
      "Em viagem", 
      Colors.grey,
      null,
    );

    LatLng posicaoOrigem = LatLng(
      _dadosRequisicao["motorista"]["latitude"], 
      _dadosRequisicao["motorista"]["longitude"]
    );

    LatLng posicaoDestino = LatLng(
      _dadosRequisicao["destino"]["latitude"], 
      _dadosRequisicao["destino"]["longitude"]
    );

    final Marcador marcador1 = Marcador(
      "motorista",
      posicaoOrigem,
      "local motorista"
    );

    final Marcador marcador2 = Marcador(
      "destino",
      posicaoDestino,
      "destino passageiro"
    );

    _exibirDoisMarcadores(marcador1, marcador2);

    _movimentarCameraBounds(marcador1.localizcao, marcador2.localizcao);
  }

  void _aceitarCorrida(){

    //Recuperar dados do motorista
    UsuarioFirebase.getDadosUsuario()
      .then((motorista){

        motorista.latitude = _localMotorista!.latitude;
        motorista.longitude = _localMotorista!.longitude;

        _firestore.collection("Requisicoes")
          .doc(_idRequisicao)
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
              idRequisicao: _idRequisicao!, 
              idUsuario   : motorista.idUsuario!, 
              status      : StatusRequisicao.aCaminho
            );

            _firestore.collection("requisicao_ativa_motorista")
              .doc(motorista.idUsuario)
              .set(requisicaoAtivaMotorista.toMap());
          });
      });
  }

  void _recuperarRequisicao(){

    final idRequisicao = widget.idRequisicao;

    _firestore.collection("Requisicoes")
      .doc(idRequisicao).get().then((documento){

        if(documento.data() != null){


        }
      });
  }

  @override
  void initState() {
    super.initState();

    _idRequisicao = widget.idRequisicao;

    if(_locationPermission != LocationPermission.always){
      _checkPermission();
    }
    _adicionarListenerRequisicao();
    //_recuperaUltimaLocalizacao();
    _addListenerPosicao();
     //_recuperarRequisicao();
  }

  @override
  Widget build  (BuildContext context ) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Painel Corrida - $_mensagemStatus"),
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
                  : null, 
                child: Text(_textoBotao)
              ),
            )
          )
        ],
      ),  
    );
  }
}