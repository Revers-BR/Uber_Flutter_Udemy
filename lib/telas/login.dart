import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uber_flutter_udemy/model/usuario.dart';

class Login extends StatefulWidget {

  const Login({super.key});

  @override
  State<Login> createState() => _Login(); 
}

class _Login extends State<Login> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController(text: "passageiro@gmail.com");
  final TextEditingController _senhaController = TextEditingController(text: "1234567");
  
  String _msgErro = "";
  bool _carregando = false;

  void _logarUsuario( ModelUsuario usuario){

    _auth.signInWithEmailAndPassword(
      email: usuario.email, 
      password: usuario.senha
    ).then(
      (usuarioFirebase) => _redirecionaPainelPorTipoUsuario(usuarioFirebase.user!.uid)
    ).catchError((_) => {
      setState(() {
        _msgErro = "Erro ao logar usuário, verifique email e senha!";
        _carregando = false;
      })
    });
  }

  void _redirecionaPainelPorTipoUsuario(String idUsuario){

    _firestore.collection("Usuarios")
      .doc(idUsuario)
      .get()
      .then((documento){
        final String tipoUsuario = documento["tipoUsuario"];

        String rota = "/painel-";

        switch (tipoUsuario) {
          case "Motorista":
            rota += "motorista";
            break;
          case "Passageiro":
            rota += "passageiro";
        }

        setState(() => _carregando = false);

        Navigator.pushNamedAndRemoveUntil(
          context, 
          rota, 
          (route) => false
        );
      });
  }

  _verificarUsuarioLogado(){
    final User? usuario = _auth.currentUser;

    if(usuario != null) _redirecionaPainelPorTipoUsuario(usuario.uid);
  }

  void _validarDados(){

    setState(() => _carregando = true);

    final email = _emailController.text;
    final senha = _senhaController.text;

    if((email.isNotEmpty && email.contains('@')) && senha.isNotEmpty){

      final ModelUsuario usuario = ModelUsuario();

      usuario.email = email;
      usuario.senha = senha;

      _logarUsuario(usuario);

    }else {
      setState((){
        _msgErro = "Erro ao tentar se autenticar, verifique email e a senha!";
        _carregando = false;
      });
    }
  }
  
  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
  }

  @override
  Widget build (BuildContext context) {

    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("imagens/fundo.png"),
              fit: BoxFit.cover
            )
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      "imagens/logo.png",
                      width: 200, 
                      height: 150
                    ),
                  ),
                
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: TextField(
                      controller: _emailController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 20),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "e-mail",
                        contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)
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
                          borderRadius: BorderRadius.circular(32)
                        )
                      ),
                    ),
                  ),
                
                  ElevatedButton(
                    onPressed: _validarDados, 
                    child: const Text("Entrar")
                  ),
                
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, "/cadastro"),
                    child: const Center(
                      child: Text(
                        "Não tem conta? cadastre-se!",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                    ) 
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: _carregando 
                          ? const LinearProgressIndicator(color: Colors.white)
                          : Text(
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