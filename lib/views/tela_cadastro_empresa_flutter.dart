import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_mapas/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';


class CadastroEmpresaScreen extends StatefulWidget {
  @override
  _CadastroEmpresaScreenState createState() => _CadastroEmpresaScreenState();
}

class _CadastroEmpresaScreenState extends State<CadastroEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nomeSocial = '';
  String _emailComercial = '';
  String _cnpj = '';
  String _senha = '';
  String _confirmSenha = '';
  bool _isLoading = false;

  final _cnpjController = MaskedTextController(mask: '00.000.000/0000-00');

  void _submitForm() async{
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_senha != _confirmSenha) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('As senhas não coincidem')),
        );
        return;
      }
      

      setState(() {
        _isLoading = true;
      });

      try {
        // Registrar o usuário no Firebase
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _emailComercial, password: _senha);
        print('Usuário registrado: ${userCredential.user!.uid}');

        // Armazenar informações adicionais no Firestore
        await FirebaseFirestore.instance
            .collection('empresas')
            .doc(userCredential.user!.uid)
            .set({
          'nomeSocial': _nomeSocial,
          'emailComercial': _emailComercial,
          'cnpj': _cnpj,
          'tipo': 'empresa', 
        });

        // Exibir mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pushReplacementNamed(context, "/tela-principal");
      } on FirebaseAuthException catch (e) {
        // Tratar erros de autenticação
        String message;
        if (e.code == 'email-already-in-use') {
          message = 'Este email já está em uso.';
        } else if (e.code == 'weak-password') {
          message = 'A senha é muito fraca.';
        } else {
          message = 'Erro no cadastro: ${e.message}';
        }

        // Exibir mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final FirebaseAuthServices _auth = FirebaseAuthServices();

  TextEditingController _socialnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  // TextEditingController _cnpjController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _socialnameController.dispose();
    _emailController.dispose();
    _cnpjController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.green[50],
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Cadastro de Empresa',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            TextFormField(
                              controller: _socialnameController,
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.business, color: Colors.grey),
                                hintText: 'Nome Social da Empresa',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'Por favor, insira o nome social da empresa'
                                  : null,
                              onSaved: (value) => _nomeSocial = value!,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.email, color: Colors.grey),
                                hintText: 'Email Comercial',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty)
                                  return 'Por favor, insira o email comercial';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Por favor, insira um email válido';
                                }
                                return null;
                              },
                              onSaved: (value) => _emailComercial = value!,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _cnpjController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.business_center,
                                    color: Colors.grey),
                                hintText: 'CNPJ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value!.isEmpty)
                                  return 'Por favor, insira o CNPJ';
                                if (value.length != 18) // conta os caracteres especiais (. e /)
                                  return 'O CNPJ deve ter 14 dígitos';
                                return null;
                              },
                              onSaved: (value) => _cnpj = value!,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.lock, color: Colors.grey),
                                hintText: 'Senha',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) => value!.length < 6
                                  ? 'A senha deve ter pelo menos 6 caracteres'
                                  : null,
                              onSaved: (value) => _senha = value!,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.lock, color: Colors.grey),
                                hintText: 'Confirmar senha',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) => value!.isEmpty
                                  ? 'Por favor, confirme sua senha'
                                  : null,
                              onSaved: (value) => _confirmSenha = value!,
                            ),
                            SizedBox(height: 24),
                            _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : ElevatedButton(
                                    child: Text('Cadastrar Empresa'),
                                    onPressed: _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      textStyle: TextStyle(fontSize: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                            SizedBox(height: 16),
                            Text(
                              'Junte-se a nós na missão de tornar o mundo mais sustentável!',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _signUp() async {
  //   String socialname = _socialnameController.text;
  //   String email = _emailController.text;
  //   String cnpj = _cnpjController.text;
  //   String password = _passwordController.text;

  //   User? user = await _auth.signUpWithEmailAndPassword(email, password);

  //   if (user != null) {
  //     print("User is successfully created");
  //     Navigator.pushReplacementNamed(context, "/tela-principal");
  //   } else {
  //     print("Erro!");
  //   }
  // }

}
