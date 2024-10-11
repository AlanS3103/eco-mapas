// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'tela_cadastro_pessoa_flutter.dart';
import 'tela_login_reciclagem_flutter.dart';
import 'tela_cadastro_empresa_flutter.dart';
import 'tela_principal_flutter.dart';

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
      },
      initialRoute: "/tela-principal",
    );
  }
}
