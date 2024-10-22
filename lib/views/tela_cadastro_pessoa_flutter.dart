import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth para autenticação
import 'tela_cadastro_empresa_flutter.dart'; // Importe a tela de cadastro de empresas

class CadastroPessoaScreen extends StatefulWidget {
  @override
  _CadastroPessoaScreenState createState() => _CadastroPessoaScreenState();
}

class _CadastroPessoaScreenState extends State<CadastroPessoaScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  String _email = '';
  String _senha = '';
  String _confirmSenha = '';
  bool _isLoading = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        // Registrar o usuário no Firebase
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _senha);
        print('Usuário registrado: ${userCredential.user!.uid}');

        // Exibir mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
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
                        Icons.recycling,
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
                              'Cadastre-se para Reciclar',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            TextFormField(
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.person, color: Colors.grey),
                                hintText: 'Nome',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'Por favor, insira seu nome'
                                  : null,
                              onSaved: (value) => _nome = value!,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.email, color: Colors.grey),
                                hintText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty)
                                  return 'Por favor, insira seu email';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Por favor, insira um email válido';
                                }
                                return null;
                              },
                              onSaved: (value) => _email = value!,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
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
                            // SizedBox(height: 16),
                            // TextFormField(
                            //   decoration: InputDecoration(
                            //     prefixIcon:
                            //         Icon(Icons.lock, color: Colors.grey),
                            //     hintText: 'Confirmar senha',
                            //     border: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(8),
                            //     ),
                            //   ),
                            //   obscureText: true,
                            //   validator: (value) {
                            //     if (value!.isEmpty)
                            //       return 'Por favor, confirme sua senha';
                            //     if (value != _senha)
                            //       return 'As senhas não coincidem';
                            //     return null;
                            //   },
                            //   onSaved: (value) => _confirmSenha = value!,
                            // ),
                            SizedBox(height: 24),
                            _isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                    child: Text('Cadastrar'),
                                    onPressed: _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      textStyle: TextStyle(fontSize: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: Icon(Icons.business),
                              label: Text('Sou empresa'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CadastroEmpresaScreen()),
                                );
                              },
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
                              'Junte-se a nós na missão de tornar o mundo mais verde!',
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
}
