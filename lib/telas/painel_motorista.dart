import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_flutter_udemy/util/status_requisicao.dart';
import 'package:uber_flutter_udemy/util/usuario_firebase.dart';

class PainelMotorista extends StatefulWidget {

  const PainelMotorista({super.key});

  @override
  State<PainelMotorista> createState() => _PainelMotorista();
}

class _PainelMotorista extends State<PainelMotorista> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<QuerySnapshot> _streamController = StreamController.broadcast();

  final List<String> _itensMenu = [
    "Configurações","Deslogar"
  ];

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

  void _adicionarListenerRequisicao(){

    _firestore.collection("Requisicoes")
      .where("status", isEqualTo: StatusRequisicao.aguardando)
      .snapshots()
      .listen(_streamController.add);
  }

  void _recuperarRequisicaoAtiva(){

    final String idMotorista = UsuarioFirebase.getUsuarioAtual().uid;
    _firestore.collection("requisicao_ativa_motorista")
      .doc(idMotorista)
      .get().then((requisicaoAtiva){

        if(requisicaoAtiva.data() == null){
          _adicionarListenerRequisicao();
        }else{
          final String idRequisicao = requisicaoAtiva["idRequisicao"];
          
          Navigator.pushReplacementNamed(
            context, 
            "/corrida",
            arguments: idRequisicao,
          );
        }
      });
  }

  @override
  void initState() {
    super.initState();
    _recuperarRequisicaoAtiva();
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
      
      body: StreamBuilder(
        stream: _streamController.stream, 
        builder: (context, snapshot) {

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Column(
                  children: [
                    Text("Carregando requisições...."),
                    LinearProgressIndicator()
                  ],
                ),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              
              if(snapshot.hasError)return const Center( child: Text("Erro ao carregar requisições"));

              if(!snapshot.hasData || snapshot.data!.docs.isEmpty)return const Center( child: Text("Você não tem requisição disponivel!"));

              final List<DocumentSnapshot> lista = snapshot.data!.docs;

              return ListView.separated(
                itemCount: lista.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.grey), 
                itemBuilder: (___, index) {

                  final requisicao = lista[index];

                  final nome = requisicao["passageiro"]["nome"];
                  final rua = requisicao["destino"]["rua"];
                  final numero = requisicao["destino"]["numero"];
                  final idRequisicao = requisicao["id"];

                  return ListTile(
                    title: Text(nome),
                    onTap: () => Navigator.pushNamed(
                      context, 
                      "/corrida",
                      arguments: idRequisicao,
                    ),
                    subtitle: Text("Destino: $rua, $numero"),
                  );
                }, 
              );
          }
        },
      ),
    );
  }
}