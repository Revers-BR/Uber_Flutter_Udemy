import 'package:flutter/material.dart';
import 'package:uber_flutter_udemy/telas/cadastro.dart';
import 'package:uber_flutter_udemy/telas/corrida.dart';
import 'package:uber_flutter_udemy/telas/home.dart';
import 'package:uber_flutter_udemy/telas/login.dart';
import 'package:uber_flutter_udemy/telas/painel_motorista.dart';
import 'package:uber_flutter_udemy/telas/painel_passageiro.dart';

class Rotas {

  static Route<dynamic> gerarRotas(RouteSettings settings) {

    final args = settings.arguments;

    Widget tela = const Home();

    switch (settings.name) {
      case "/":
        tela = const Home();
        break;
      case "/login":
        tela = const Login();
        break;
      case "/cadastro":
        tela = const Cadastro();
        break;
      case "/corrida":
        tela = Corrida(idRequisicao: args as String);
        break;
      case "/painel-passageiro":
        tela = const PainelPassageiro();
        break;
      case "/painel-motorista":
        tela = const PainelMotorista();
        break;
      default:
        tela = _ErroRota();
    }

    return MaterialPageRoute(
      builder: (_) => tela
    );
  }
}

class _ErroRota extends StatelessWidget {

  @override
  Widget build ( BuildContext context ) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tela não encontrado"),
      ),
      body: const Center(
        child: Text("Tela não encontrado"),
      ),
    );
  }
}