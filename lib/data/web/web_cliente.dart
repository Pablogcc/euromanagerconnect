import 'dart:io';

import '../../config/web_config.dart';

// Cliente web sencillo para probar conectividad con el servidor.
class WebCliente {
  Future<void> testConnection(WebConfig config) async {
    if (config.url.trim().isEmpty) {
      throw Exception('La URL no puede estar vacia.');
    }

    final uri = Uri.parse(config.url.trim());
    if (uri.scheme.isEmpty) {
      throw Exception('La URL debe incluir http:// o https://');
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri).timeout(
            const Duration(seconds: 6),
          );
      final response = await request.close().timeout(
            const Duration(seconds: 6),
          );
      if (response.statusCode < 200 || response.statusCode >= 400) {
        throw Exception('Respuesta HTTP no valida: ${response.statusCode}');
      }
    } finally {
      client.close(force: true);
    }
  }
}
