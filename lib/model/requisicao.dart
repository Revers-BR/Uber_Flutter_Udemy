import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uber_flutter_udemy/model/destino.dart';
import 'package:uber_flutter_udemy/model/usuario.dart';
import 'package:uber_flutter_udemy/util/status_requisicao.dart';

class ModelRequisicao {

  late String id;
  ModelUsuario passageiro;
  ModelUsuario? motorista;
  ModelDestino destino;
  String status = StatusRequisicao.aguardando;

  ModelRequisicao({
    required this.passageiro,
    required this.destino,
  }){
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentReference reference = firestore.collection("Requisicoes").doc();

    id = reference.id;
  }

  Map<String, dynamic> toMap () {

    return {
      "id"        : id,
      "passageiro": passageiro.toMap(),
      "motorista" : motorista?.toMap(),
      "destino"   : destino.toMap(),
      "status"    : status
    };
  }
}