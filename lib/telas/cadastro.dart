import 'package:flutter/material.dart';
import 'package:uber_flutter_udemy/model/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cadastro extends StatefulWidget {

  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _Cadastro();
}

class _Cadastro extends State<Cadastro> {

  final TextEditingController _nomeController = TextEditingController(text: "Motorista");
  final TextEditingController _emailController = TextEditingController(text: "motorista@gmail.com");
  final TextEditingController _senhaController = TextEditingController(text: "1234567");
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _tipoUsuario = false;
  String _msgErro = "";

  void _cadastrarUsuario(ModelUsuario usuario){

    _auth.createUserWithEmailAndPassword(
      email: usuario.email, 
      password: usuario.senha
    ).then((usuarioFirebase){

      usuario.idUsuario = usuarioFirebase.user!.uid;

      _firestore.collection("Usuarios")
        .doc(usuario.idUsuario)
        .set( usuario.toMap())
        .then((_){

          String rota = "/painel-";

          switch (usuario.getTipoUsuario) {
            case "Motorista":
              rota += "motorista";
              break;
            case "Passageiro":
              rota += "passageiro";
          }

          Navigator.pushNamedAndRemoveUntil(context, rota, (route) => false);
        }).catchError((_){
          _msgErro = "Erro ao inserir dados no banco de dados!";
        });
    }).catchError((_){
      _msgErro = "Erro ao cadastrar usuário!";
    });
  }

  void _validarDados(){

    final nome = _nomeController.text;
    final email = _emailController.text;
    final senha = _senhaController.text;

    if(nome.isNotEmpty && (email.isNotEmpty && email.contains('@')) && senha.length > 6){

      final ModelUsuario usuario = ModelUsuario();
      usuario.email = email;
      usuario.nome = nome;
      usuario.senha = senha;
      usuario.tipoUsuario = _tipoUsuario;

      _cadastrarUsuario(usuario);

    }else {
      setState(() => _msgErro = 
        "Verifique se campo nome, email, senha não está vazio\n\n"
        "E se campo e-mail tem @, e senha tem no minimo 7 caracters"
      );
    }
  }

  @override
  Widget build (BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro"),
      ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [   
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: TextField(
                      controller: _nomeController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 20),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Nome completo",
                        contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)
                        )
                      ),
                    ),
                  ),
   
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(fontSize: 20),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "e-mail",
                        contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)
                        )
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 32, top: 8),
                    child: TextField(
                      controller: _senhaController,
                      obscureText: true,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "senha",
                        contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)
                        )
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Center(
                      child: Row(
                        children: [
                          const Text("Passageiro"),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Switch(
                              value: _tipoUsuario, 
                              onChanged: (valor) => setState(() => _tipoUsuario = valor),
                            ),
                          ),
                          const Text("Motorista")
                        ],
                      ),
                    ),
                  ),
                
                  ElevatedButton(
                    onPressed: _validarDados, 
                    child: const Text("Cadastrar")
                  ),
                
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        _msgErro,
                        style: const TextStyle(
                          color: Colors.red
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ) 
        ),
    
    );
  }
}