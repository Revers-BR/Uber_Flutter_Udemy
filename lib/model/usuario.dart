class ModelUsuario {

  late String nome;
  late String email;
  late String senha;
  late String idUsuario;
  late String _tipoUsuario;

  Map<String, dynamic> toMap (){

    return {
      "nome": nome,
      "email": email,
      "tipoUsuario": _tipoUsuario
    };
  }

  String get getTipoUsuario => _tipoUsuario; 

  set tipoUsuario( bool tipoUsuario){
    
    _tipoUsuario = tipoUsuario ? "Motorista" : "Passageiro";
  }
}