import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_mapas/views/tela_perfil_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_ajuda_flutter.dart';
import 'tela_login_reciclagem_flutter.dart';
import 'tela_principal_flutter.dart';
import 'tela_cadastro_pessoa_flutter.dart';
import 'tela_cadastro_empresa_flutter.dart';
import 'tela_configuracoes_flutter.dart';

class EcoMapasApp extends StatefulWidget {
  @override
  _EcoMapasAppState createState() => _EcoMapasAppState();

  static _EcoMapasAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_EcoMapasAppState>();
}

class _EcoMapasAppState extends State<EcoMapasApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String themeMode = prefs.getString('themeMode') ?? 'light';
      switch (themeMode) {
        case 'system':
          _themeMode = ThemeMode.system;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.light;
      }
    });
  }

  void setThemeMode(String themeMode) {
    setState(() {
      switch (themeMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('themeMode', themeMode);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        dialogBackgroundColor: Colors.grey[900],
      ),
      themeMode: _themeMode,
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
                          return Center(
                              child: Text('Dados do perfil não encontrados.'));
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
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}