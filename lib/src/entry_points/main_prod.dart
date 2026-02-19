import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options_prod.dart';
import '../flavor_config/flavors.dart';
import '../../main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicijalizuje PROD Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  F.appFlavor = Flavor.prod;
  
  runFlavoredApp();
}