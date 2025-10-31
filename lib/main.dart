import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'app_router.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firestore: no cache and ignore undefined properties to avoid write 400s
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    ignoreUndefinedProperties: true,
  );

  // Simple startup log
  debugPrint('🔥 Firebase listo (web=$kIsWeb)');
  runApp(const CitasApp());
}

class CitasApp extends StatelessWidget {
  const CitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citas MVP',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: onGenerateRoute,
      initialRoute: '/',
      home: const AuthGate(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F1F6),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2962FF)),
      ),
    );
  }
}

