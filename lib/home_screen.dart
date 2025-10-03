import 'package:flutter/material.dart';
import 'auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await auth.signOut();
            Navigator.pushReplacementNamed(context, "/login");
          },
          child: const Text("Cerrar sesión"),
        ),
      ),
    );
  }
}
