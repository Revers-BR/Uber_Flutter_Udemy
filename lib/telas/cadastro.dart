import 'package:flutter/material.dart';

class Cadastro extends StatefulWidget {

  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _Cadastro();
}

class _Cadastro extends State<Cadastro> {

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _tipoUsuario = false;

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
                    onPressed: (){}, 
                    child: const Text("Cadastrar")
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