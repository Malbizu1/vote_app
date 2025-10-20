import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vote_app/core/auth/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: () async {
              await AuthService().signOut();
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión cerrada correctamente')),
              );
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No hay usuario autenticado'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),

            // Nombre y correo
            Text(
              user.displayName ?? 'Usuario sin nombre',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user.email ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "UID: ${user.uid}",
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const Divider(height: 40),

            // Sección de historial (placeholder)
            const Text(
              "Historial de votaciones",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPlaceholderHistory(),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService().signOut();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text("Cerrar sesión"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Simulación de historial (para completar más adelante con datos reales)
  Widget _buildPlaceholderHistory() {
    final fakeHistory = [
      {'title': 'Elección Delegado', 'status': 'Completada'},
      {'title': 'Encuesta Satisfacción', 'status': 'Pendiente'},
      {'title': 'Votación Reforma', 'status': 'Completada'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fakeHistory.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = fakeHistory[i];
        return ListTile(
          leading: const Icon(Icons.how_to_vote),
          title: Text(item['title']!),
          subtitle: Text('Estado: ${item['status']}'),
          trailing: Icon(
            item['status'] == 'Completada'
                ? Icons.check_circle
                : Icons.hourglass_empty,
            color:
            item['status'] == 'Completada' ? Colors.green : Colors.orange,
          ),
        );
      },
    );
  }
}
