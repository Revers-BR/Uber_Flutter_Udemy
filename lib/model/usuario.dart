class ModelUsuario {

  late String nome;
  late String email;
  late String senha;
  String? idUsuario;
  late String _tipoUsuario;

  double? latitude;
  double? longitude;

  Map<String, dynamic> toMap (){

    return {
      "id"          : idUsuario,
      "nome"        : nome,
      "email"       : email,
      "latitude"    : latitude,
      "longitude"   : longitude,
      "tipoUsuario" : _tipoUsuario,
    };
  }

  String get getTipoUsuario => _tipoUsuario; 

  set tipoUsuario( dynamic tipoUsuario){

    if(tipoUsuario is String){
      _tipoUsuario = tipoUsuario;
    }else if(tipoUsuario is bool){
      _tipoUsuario = tipoUsuario ? "Motorista" : "Passageiro";
    }
  }
}