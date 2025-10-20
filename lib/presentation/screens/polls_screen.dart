import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vote_app/core/network/dio_client.dart';
import 'package:vote_app/data/models/poll_model.dart';
import 'package:vote_app/data/repositories/poll_repository.dart';
import 'package:vote_app/presentation/widgets/error_display.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  late final PollRepository repo;
  late Future<List<PollModel>> future;

  @override
  void initState() {
    super.initState();
    repo = PollRepository(DioClient());
    future = repo.listPolls();
  }

  void _retry() {
    setState(() {
      future = repo.listPolls();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encuestas disponibles')),
      body: FutureBuilder<List<PollModel>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            final err = snap.error;
            return ErrorDisplay(
              message: 'Error al obtener encuestas: $err',
              onRetry: _retry,
            );
          }
          final items = snap.data ?? const [];
          if (items.isEmpty) {
            return ErrorDisplay(
              message: 'No hay encuestas disponibles',
              onRetry: _retry,
              isWarning: true,
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = items[i];
              return ListTile(
                title: Text(p.title ?? 'Encuesta'),
                subtitle: Text(p.description ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: navegar a detalle
                },
              );
            },
          );
        },
      ),
    );
  }
}
