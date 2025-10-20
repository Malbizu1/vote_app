import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vote_app/core/auth/auth_service.dart';
import 'package:vote_app/core/network/dio_client.dart';
import 'package:vote_app/presentation/screens/polls_screen.dart';
import 'package:vote_app/presentation/screens/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vote App 🗳️"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              await AuthService().signOut();
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sesión cerrada correctamente")),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Información del usuario
            CircleAvatar(
              radius: 45,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 45)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'Usuario',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 32),

            // Botón para probar conexión a la API
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.cloud),
              label: const Text("Probar conexión API"),
              onPressed: () async {
                final client = DioClient();
                try {
                  final response = await client.dio.get('/v1/polls/');
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("✅ API OK (${response.statusCode})")),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Error API: $e")),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Ir a encuestas
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.how_to_vote),
              label: const Text("Ver encuestas"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PollsScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Ir al perfil
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.person),
              label: const Text("Ver perfil"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
