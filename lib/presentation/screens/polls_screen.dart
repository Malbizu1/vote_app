import 'package:flutter/material.dart';
import 'package:vote_app/data/models/poll_model.dart';
import 'package:vote_app/data/repositories/poll_repository.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  final PollRepository _repository = PollRepository();
  bool _loading = true;
  String? _error;
  List<PollModel> _polls = [];

  @override
  void initState() {
    super.initState();
    _fetchPolls();
  }

  Future<void> _fetchPolls() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _repository.fetchPolls();
      setState(() => _polls = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Encuestas disponibles"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchPolls),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorDisplay(message: _error!, onRetry: _fetchPolls);
    }

    if (_polls.isEmpty) {
      return const Center(
        child: Text("No hay encuestas disponibles"),
      );
    }

    return ListView.builder(
      itemCount: _polls.length,
      itemBuilder: (context, index) {
        final poll = _polls[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListTile(
            title: Text(poll.title),
            subtitle: Text(poll.description ?? "Sin descripción"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Seleccionaste ${poll.pollToken}")),
              );
            },
          ),
        );
      },
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorDisplay({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(message, textAlign: TextAlign.center),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
