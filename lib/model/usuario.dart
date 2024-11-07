class ModelUsuario {

  late String nome;
  late String email;
  late String senha;
  String? idUsuario;
  late String _tipoUsuario;

  Map<String, dynamic> toMap (){

    return {
      "id"          : idUsuario,
      "nome"        : nome,
      "email"       : email,
      "tipoUsuario" : _tipoUsuario
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