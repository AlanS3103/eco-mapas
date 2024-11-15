import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaPerfil extends StatelessWidget {
  final String userType;

  const TelaPerfil({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection(userType == 'empresa' ? 'empresas' : 'users')
              .doc(user?.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Dados do perfil não encontrados.'));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Nome:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  userType == 'empresa'
                      ? userData['nomeSocial'] ?? 'Nome Social não disponível'
                      : userData['nome'] ?? 'Nome não disponível',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Email:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? 'Email não disponível',
                  style: TextStyle(fontSize: 16),
                ),
                if (userType == 'empresa') ...[
                  SizedBox(height: 16),
                  Text(
                    'CNPJ:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userData['cnpj'] ?? 'CNPJ não disponível',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    
                  },
                  child: Text('Editar Perfil'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}