import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_flutter_udemy/model/destino.dart';
import 'package:uber_flutter_udemy/model/requisicao.dart';
import 'package:uber_flutter_udemy/model/requisicao_ativa.dart';
import 'package:uber_flutter_udemy/model/usuario.dart';
import 'package:uber_flutter_udemy/util/status_requisicao.dart';
import 'package:uber_flutter_udemy/util/usuario_firebase.dart';

class PainelPassageiro extends StatefulWidget {

  const PainelPassageiro({super.key});

  @override
  State<PainelPassageiro> createState() => _PainelPassageiro();
}

class _PainelPassageiro extends State<PainelPassageiro> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<Marker> _marcadores = {};

  final List<String> _itensMenu = [
    "Configurações","Deslogar"
  ];

  final Completer<GoogleMapController> _googleMapController = Completer<GoogleMapController>();

  final TextEditingController _destinoController = TextEditingController(text: "Estrada do rufino, 937");

  LocationPermission _locationPermission = LocationPermission.denied;

  StreamSubscription<Position>? _positionStream;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscriptionRequisicao;
  
  Map<String, dynamic>? _dadosRequisicao;

  Position? _localPosicaoPassageiro;

  bool _exibirCaixaDestino = true;
  String _textoBotao = "Chamar uber";
  Function? _funcaoBotao;
  Color? _corBotao = Colors.blue[300];

  String? _idRequisicao;

  CameraPosition _cameraPosition = const CameraPosition(
          target: LatLng(-23.711993111425905, -46.6249616576713),
          zoom: 18
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

        final LatLng posicao = LatLng(latitude, longitude);

        _exibirMarcadores(posicao);

        setState(() {
          _cameraPosition = CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 18
          );

          _movimentarCameraPosicao(_cameraPosition);

          _localPosicaoPassageiro = position;
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

    _positionStream =  Geolocator.getPositionStream(locationSettings: locationSettings).listen( (position){

        if(_idRequisicao != null && _idRequisicao!.isNotEmpty){

          final LatLng posicao = LatLng(
            position.latitude, position.longitude
          );

          UsuarioFirebase.atulaizarDadosLocalizacao(_idRequisicao!, posicao);

        }else {
          setState( (){
            _localPosicaoPassageiro = position;
            _statusUberNaoChamado();
          });
        }
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

  void _exibirMarcadores(LatLng position){

    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final ImageConfiguration configuration = ImageConfiguration(
      devicePixelRatio: devicePixelRatio
    );

    const assetName = "imagens/passageiro.png";
    
    // ignore: deprecated_member_use
    BitmapDescriptor.fromAssetImage(configuration, assetName).then((icon){
      
      final Marker marcadorPassageiro = Marker(
        markerId: const MarkerId("marcador-passageiro"),
        position: position, 
        infoWindow: const InfoWindow(title: "meu local"),
        icon: icon
      );

      if(_marcadores.isNotEmpty)_marcadores.removeWhere((element) => element.markerId == marcadorPassageiro.markerId);
      
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
                      onPressed: (){
                        _salvarRequisicao(destino);
                        Navigator.pop(context);
                      }, 
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

  void _salvarRequisicao( ModelDestino destino) async {

    final ModelUsuario passageiro =  await UsuarioFirebase.getDadosUsuario();
    passageiro.latitude = _localPosicaoPassageiro!.latitude;
    passageiro.longitude = _localPosicaoPassageiro!.longitude;

    final ModelRequisicao requisicao = ModelRequisicao(passageiro: passageiro, destino: destino);

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    firestore.collection("Requisicoes")
      .doc(requisicao.id)
      .set( requisicao.toMap() );

    final RequisicaoAtiva requisicaoAtiva = RequisicaoAtiva(
      idRequisicao: requisicao.id, 
      idUsuario: passageiro.idUsuario!, 
      status: requisicao.status
    );

    _firestore.collection("requisicao_ativa")
      .doc(requisicaoAtiva.idUsuario)
      .set( requisicaoAtiva.toMap() );

    _statusAguardandoUber();
  }

  void _alterarBotaoPrincipal(String texto, Color cor, Function? funcao){

    if(mounted){

      setState(() {
        _textoBotao = texto;
        _corBotao = cor;
        _funcaoBotao = funcao;
      });
    }

  }

  void _statusUberNaoChamado(){

    _exibirCaixaDestino = true;

    _alterarBotaoPrincipal(
      "Chamar uber", 
      Colors.blue[300]!,
      _chamarUber
    );

    if(_localPosicaoPassageiro != null){

      final LatLng position = LatLng(
        _localPosicaoPassageiro!.latitude, 
        _localPosicaoPassageiro!.longitude
      );

      _exibirMarcadores(position);
      final CameraPosition cameraPosition = CameraPosition(
        target: position,
        zoom: 18
      );
      _movimentarCameraPosicao(cameraPosition);
    }
  }

  void _statusAguardandoUber(){

    _exibirCaixaDestino = false;

    _alterarBotaoPrincipal(
      "Cancelar", 
      Colors.red,
      _cancelarUber
    );

    final latitude = _dadosRequisicao!["passageiro"]["latitude"];
    final longitude = _dadosRequisicao!["passageiro"]["longitude"];

    final LatLng position = LatLng(
      latitude, longitude
    );

    _exibirMarcadores(position);
    final CameraPosition cameraPosition = CameraPosition(
      target: position,
      zoom: 18
    );
    _movimentarCameraPosicao(cameraPosition);
  }

  Future<Marker> _criarMarcador(String icone, LatLng posicao, String idMarcador, String titulo) async {
    
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final ImageConfiguration configuration = ImageConfiguration(
      devicePixelRatio: devicePixelRatio
    );

    final assetName = "imagens/$icone.png";
    
    // ignore: deprecated_member_use
    final icon = await BitmapDescriptor.fromAssetImage(configuration, assetName);
      
    final Marker marcador = Marker(
      markerId: MarkerId("marcador-$idMarcador"),
      position: posicao, 
      infoWindow: InfoWindow(title: titulo),
      icon: icon
    );

    return marcador;
  }

  void _exibirDoisMarcadores(LatLng posicaoPassageiro, LatLng posicaoMotorista) async {

    final Set<Marker> marcadores = {};

    final marcadorMotorista  = await _criarMarcador("motorista", posicaoMotorista, "motorista", "Localização do motorista");

    final marcadorPassageiro = await _criarMarcador("passageiro", posicaoPassageiro, "passageiro", "Localização do passageiro");

    marcadores.addAll({
      marcadorPassageiro,
      marcadorMotorista
    });
    setState(() => _marcadores = marcadores);
  }

  void _statusACaminho(){

    _exibirCaixaDestino = false;

    _alterarBotaoPrincipal(
      "Motorista a Caminho", 
      Colors.grey,
      null
    );

    LatLng posicaoPassageiro = LatLng(
      _dadosRequisicao!["passageiro"]["latitude"], 
      _dadosRequisicao!["passageiro"]["longitude"]
    );

    LatLng posicaoMotorista = LatLng(
      _dadosRequisicao!["motorista"]["latitude"], 
      _dadosRequisicao!["motorista"]["longitude"]
    );

    _exibirDoisMarcadores(posicaoPassageiro, posicaoMotorista);

    double sLat, nLat, sLon, nLon;

    if(posicaoMotorista.latitude <= posicaoPassageiro.latitude){
      sLat = posicaoMotorista.latitude;
      nLat = posicaoPassageiro.latitude;
    }else{
      sLat = posicaoPassageiro.latitude;
      nLat = posicaoMotorista.latitude;
    }

    if(posicaoMotorista.longitude <= posicaoPassageiro.longitude){
      sLon = posicaoMotorista.longitude;
      nLon = posicaoPassageiro.longitude;
    }else{
      sLon = posicaoPassageiro.longitude;
      nLon = posicaoMotorista.longitude;
    }

    LatLng southwest = LatLng( sLat, sLon);

    LatLng northeast = LatLng(nLat, nLon );

    LatLngBounds latLngBounds = LatLngBounds(
      southwest: southwest, 
      northeast: northeast
    );

    _movimentarCameraBounds(latLngBounds);
  }

  void _movimentarCameraBounds(LatLngBounds latLngBounds){
    
    _googleMapController.future.then((googleMapController){
      googleMapController.moveCamera(
        CameraUpdate.newLatLngBounds(
          latLngBounds, 
          100
        )
      );
    });
  }

  void _cancelarUber(){

    _firestore.collection("Requisicoes")
      .doc(_idRequisicao)
      .update({
        "status": StatusRequisicao.cancelado
      }).then((_){

        final idUsuario = UsuarioFirebase.getUsuarioAtual().uid;

        _firestore.collection("requisicao_ativa")
          .doc(idUsuario)
          .delete();
      });
  }

  void _recuperarRequisicaoAtiva(){
    
    final User passageiro = UsuarioFirebase.getUsuarioAtual();
    
    _firestore.collection("requisicao_ativa")
      .doc(passageiro.uid)
      .get()
      .then((documento){

        if(documento.data() != null){

          final Map<String, dynamic > dados = documento.data()!;

          _idRequisicao = dados["idRequisicao"];

          _adicionarListenerRequisicao(_idRequisicao!);

        }else {
          _statusUberNaoChamado();
        }
      });
  }

  void _adicionarListenerRequisicao( String idRequisicao){

    _subscriptionRequisicao = _firestore.collection("Requisicoes")
      .doc(idRequisicao)
      .snapshots()
      .listen((documento) {

        final data = documento.data();

        if(data != null){

          _dadosRequisicao = data;

          _idRequisicao = data["id"];
          final status  = data["status"];

          switch (status) {
            case StatusRequisicao.aguardando:
              _statusAguardandoUber();
              break;
            case StatusRequisicao.aCaminho:
              _statusACaminho();
              break;
          } 
        }
      });
  }

  @override
  void initState() {
    super.initState();
    if(_locationPermission != LocationPermission.always){
      _checkPermission();
    }
    _addListenerPosicao();
    
    _recuperarRequisicaoAtiva();
     //_recuperaUltimaLocalizacao();
     //_adicionarListenerRequisicaoAtiva();
  }

  @override
  void dispose() {
    super.dispose();
    if(_positionStream != null) _positionStream!.cancel();
    if(_subscriptionRequisicao != null)_subscriptionRequisicao!.cancel();
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
          
          Visibility(
            visible: _exibirCaixaDestino,
            child: Stack(
              children: [
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

              ],
            )
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