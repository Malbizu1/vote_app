import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar mensajes de error, vacío o advertencia,
/// con opción de reintentar la acción fallida.
///
/// Ejemplo de uso:
/// ```dart
/// ErrorDisplay(
///   message: 'No se pudo obtener las encuestas',
///   onRetry: _loadPolls,
/// )
/// ```
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isWarning;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? Colors.orange : Colors.redAccent;
    final icon = isWarning ? Icons.info_outline : Icons.error_outline;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 60),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text("Reintentar"),
              ),
          ],
        ),
      ),
    );
  }
}
