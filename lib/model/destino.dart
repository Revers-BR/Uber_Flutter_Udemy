class ModelDestino {

  final String? cidade;
  final String? cep;
  final String? bairro;
  final String? rua;
  final String? numero;

  final double latitude;
  final double longitude;

  ModelDestino({
    required this.cidade,
    required this.cep,
    required this.bairro,
    required this.rua,
    required this.numero,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap (){

    return {
      "cidade"    : cidade, 
      "cep"       : cep,
      "bairro"    : bairro,
      "rua"       : rua,
      "numero"    : numero,
      "latitude"  : latitude,
      "longitude" : longitude,
    };
  }
}