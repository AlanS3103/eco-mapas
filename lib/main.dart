import 'views/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: "eco_mapas",
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(EcoMapasApp());
}