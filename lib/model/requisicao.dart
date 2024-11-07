import 'package:uber_flutter_udemy/model/destino.dart';
import 'package:uber_flutter_udemy/model/usuario.dart';
import 'package:uber_flutter_udemy/util/status_requisicao.dart';

class ModelRequisicao {

  ModelUsuario passageiro;
  ModelUsuario? motorista;
  ModelDestino destino;
  String status = StatusRequisicao.aguardando;

  ModelRequisicao({
    required this.passageiro,
    required this.destino,
  });

  Map<String, dynamic> toMap () {

    return {

      "passageiro": passageiro.toMap(),
      "motorista" : motorista?.toMap(),
      "destino"   : destino.toMap(),
      "status"    : status
    };
  }
}