import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart'; // generado por flutterfire configure
import 'auth_service.dart';
import 'core/network/dio_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Cargar variables de entorno (.env)
  await dotenv.load(fileName: ".env");

  // 2) Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Vote App",
      home: Scaffold(
        appBar: AppBar(title: const Text("Prueba Login con Google")),
        body: Center(
          child: ElevatedButton.icon(
            onPressed: () async {
              final user = await AuthService().signInWithGoogle();

              if (user != null) {
                // ✅ Usuario logueado, probamos llamada a API
                final client = DioClient();
                try {
                  final response = await client.dio.get("/ping"); // ejemplo de endpoint
                  // Muestra respuesta de API en SnackBar
                  // (cámbialo por un endpoint real de tu API)
                  // Si no tienes, comenta esta parte
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("API dice: ${response.data}")),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error API: $e")),
                  );
                }

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Bienvenido, ${user.displayName}")),
                );
              } else {
                // Si cancelaron o falló
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Login cancelado o fallido")),
                );
              }
            },
            icon: const Icon(Icons.login),
            label: const Text("Iniciar con Google"),
          ),
        ),
      ),
    );
  }
}
