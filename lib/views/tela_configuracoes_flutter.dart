import 'package:eco_mapas/views/app.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class TelaConfiguracoes extends StatefulWidget {
  @override
  _TelaConfiguracoesState createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  String _themeMode = 'light';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = prefs.getString('themeMode') ?? 'light';
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', _themeMode);
    prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  Future<void> _clearCache() async {
    await DefaultCacheManager().emptyCache();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cache limpo com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Tema'),
              trailing: DropdownButton<String>(
                value: _themeMode,
                items: [
                  DropdownMenuItem(
                    value: 'system',
                    child: Text('Padrão do Sistema'),
                  ),
                  DropdownMenuItem(
                    value: 'light',
                    child: Text('Claro'),
                  ),
                  DropdownMenuItem(
                    value: 'dark',
                    child: Text('Escuro'),
                  ),
                ],
                onChanged: (String? value) {
                  setState(() {
                    _themeMode = value!;
                  });
                  _saveSettings();
                    // Notifique o MaterialApp sobre a mudança de tema
                    EcoMapasApp.of(context)?.setThemeMode(_themeMode);
                },
              ),
            ),
            ListTile(
              title: Text('Limpar Cache'),
              onTap: () {
                _clearCache();
              },
            ),
          ],
        ),
      ),
    );
  }
}