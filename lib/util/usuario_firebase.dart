import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_flutter_udemy/model/usuario.dart';

class UsuarioFirebase {

  static User getUsuarioAtual () {

    final FirebaseAuth auth = FirebaseAuth.instance;

    return auth.currentUser!;
  }

  static Future<ModelUsuario> getDadosUsuario () async {

    final User usuarioAtual = getUsuarioAtual();

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final DocumentSnapshot documentSnapshot = await firestore.collection("Usuarios")
      .doc(usuarioAtual.uid)
      .get();

    final ModelUsuario dadosUsuario = ModelUsuario();
    dadosUsuario.nome         = documentSnapshot["nome"];
    dadosUsuario.email        = documentSnapshot["email"];
    dadosUsuario.idUsuario    = documentSnapshot.id;
    dadosUsuario.tipoUsuario  = documentSnapshot["tipoUsuario"];

    return dadosUsuario;
  }
}