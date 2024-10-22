import 'package:flutter/material.dart';

class TelaConfiguracoes extends StatefulWidget {
  @override
  _TelaConfiguracoesState createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  bool _notificacoes = true;
  double _volume = 50;
  String _tema = 'Claro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Notificações'),
              value: _notificacoes,
              onChanged: (bool value) {
                setState(() {
                  _notificacoes = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Volume'),
            Slider(
              value: _volume,
              min: 0,
              max: 100,
              divisions: 10,
              label: _volume.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _volume = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Tema'),
            DropdownButton<String>(
              value: _tema,
              onChanged: (String? newValue) {
                setState(() {
                  _tema = newValue!;
                });
              },
              items: <String>['Claro', 'Escuro', 'Sistema']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
