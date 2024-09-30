// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'tela_cadastro_reciclagem_flutter.dart';
import 'tela_login_reciclagem_flutter.dart';
import 'tela_cadastro_empresa_flutter.dart';

class EcoMapasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      routes: {
        "/login": (context) => LoginScreen(),
        "/cadastro": (context) => CadastroReciclagemScreen(),
        "/cadastro-empresa": (context) => CadastroEmpresaScreen(),
      },
      initialRoute: "/login",
    );
  }
}
