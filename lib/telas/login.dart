import 'package:flutter/material.dart';

class Login extends StatefulWidget {

  const Login({super.key});

  @override
  State<Login> createState() => _Login(); 
}

class _Login extends State<Login> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

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
                    onPressed: (){}, 
                    child: const Text("Entrar")
                  ),
                
                  GestureDetector(
                    onTap: (){},
                    child: const Center(
                      child: Text(
                        "Não tem conta? cadastre-se!",
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                    ) 
                  ),
                
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        "Erro",
                        style: TextStyle(
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