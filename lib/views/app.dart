import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_mapas/views/tela_perfil_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tela_ajuda_flutter.dart';
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
        "/tela-principal": (context) => PrincipalScreen(userType: ''), 
        "/configuracoes": (context) => TelaConfiguracoes(),
        "/perfil": (context) => TelaPerfil(userType: ''), 
        "/ajuda": (context) => TelaAjuda(),
      },
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data == null) {
                return LoginScreen();
              } else {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(snapshot.data!.uid)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('empresas')
                            .doc(snapshot.data!.uid)
                            .get(),
                        builder: (context, empresaSnapshot) {
                          if (empresaSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!empresaSnapshot.hasData ||
                              !empresaSnapshot.data!.exists) {
                            return LoginScreen();
                          }
                          var userType = empresaSnapshot.data!['tipo'];
                          return PrincipalScreen(userType: userType);
                        },
                      );
                    }
                    var userType = userSnapshot.data!['tipo'];
                    return PrincipalScreen(userType: userType);
                  },
                );
              }
            } else {
              return LoginScreen();
            }
          }),
    );
  }
}
