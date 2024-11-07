class RequisicaoAtiva {

  final String idRequisicao;
  final String idUsuario;
  String status;

  RequisicaoAtiva({
    required this.idRequisicao,
    required this.idUsuario,
    required this.status
  });

  Map<String, dynamic> toMap () {

    return {
      "status"        : status,
      "idUsuario"     : idUsuario,
      "idRequisicao"  : idRequisicao,
    };
  }
}