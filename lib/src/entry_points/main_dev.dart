import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options_dev.dart';
import '../flavor_config/flavors.dart';
import '../../main.dart';

void main() async {
  // Osigurava da je Flutter spreman
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicijalizuje DEV Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Kaže aplikaciji da je u DEV modu
  F.appFlavor = Flavor.dev;
  
  // Pokreće aplikaciju
  runFlavoredApp();
}