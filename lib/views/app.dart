// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tela_login_reciclagem_flutter.dart';
import 'tela_principal_flutter.dart';
import 'tela_cadastro_pessoa_flutter.dart';
import 'tela_cadastro_empresa_flutter.dart';
import 'tela_configuracoes_flutter.dart';

class EcoMapasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      routes: {
        "/login": (context) => LoginScreen(),
        "/cadastro": (context) => CadastroPessoaScreen(),
        "/cadastro-empresa": (context) => CadastroEmpresaScreen(),
        "/tela-principal": (context) => PrincipalScreen(),
        "/configuracoes": (context) => TelaConfiguracoes(),
      },
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              return snapshot.data == null ? LoginScreen() : PrincipalScreen();
            } else {
              return LoginScreen();
            }
          }),
      // initialRoute: "/tela-principal",
    );
  }
}
