import 'dart:convert';
import 'dart:io';

import '../../config/web_config.dart';

// Cliente web sencillo para probar conectividad con el servidor.
class WebCliente {
  Future<void> testConnection(WebConfig config) async {
    // URL fija de la API (NocoDB). No se pide en la UI.
    const String apiBaseFija = 'https://api.dspyme.com';

    if (config.conexiones.isEmpty) {
      throw Exception('Debes indicar al menos una conexion web.');
    }

    final client = HttpClient();
    try {
      for (final conexion in config.conexiones) {
        // 1) Validaciones basicas de campos.
        final url = conexion.url.trim();
        final proyecto = conexion.proyecto.trim();
        final usuario = conexion.usuario?.trim() ?? '';
        final contrasena = conexion.contrasena ?? '';

        if (conexion.empresa.trim().isEmpty) {
          throw Exception('La empresa no puede estar vacia.');
        }
        if (url.isEmpty) {
          throw Exception('La URL no puede estar vacia.');
        }
        if (proyecto.isEmpty) {
          throw Exception('El proyecto no puede estar vacio.');
        }
        if (usuario.isEmpty || contrasena.isEmpty) {
          throw Exception('Usuario y contrasena son obligatorios.');
        }

        final uri = Uri.parse(url);
        if (uri.scheme.isEmpty || uri.host.isEmpty) {
          throw Exception('La URL no es valida (falta http/https o host): $url');
        }

        // 2) Comprobar credenciales contra el login PHP del portal.
        // Endpoint esperado: {url_portal}/api/loginportal.php
        final loginUri = uri.replace(
          path: _joinPath(uri.path, 'api/loginportal.php'),
        );
        final loginPayload = jsonEncode({
          'user': usuario,
          'password': contrasena,
          // El PHP usa este dominio para ir a la API real.
          // Aqui enviamos la URL fija de NocoDB.
          'dominio': apiBaseFija,
        });

        final loginReq = await client.postUrl(loginUri).timeout(
              const Duration(seconds: 8),
            );
        loginReq.headers.contentType = ContentType.json;
        loginReq.write(loginPayload);
        final loginResp = await loginReq.close().timeout(
              const Duration(seconds: 8),
            );

        if (loginResp.statusCode < 200 || loginResp.statusCode >= 300) {
          throw Exception(
            'Login incorrecto en $url (HTTP ${loginResp.statusCode}).',
          );
        }

        final loginBody = await loginResp.transform(utf8.decoder).join();
        final loginData = jsonDecode(loginBody);
        final token = loginData is Map ? loginData['token'] as String? : null;
        if (token == null || token.isEmpty) {
          throw Exception('El login no devolvio token en $url.');
        }

        // 3) Comprobar que el proyecto existe y es accesible en la API fija.
        // Usamos una tabla comun: Usuario (si no existe, ajustamos mas adelante).
        final apiUri = Uri.parse(apiBaseFija);
        final checkPath = '/api/v1/db/data/v1/$proyecto/Usuario/find-one';
        final checkUri = apiUri.replace(path: _joinPath(apiUri.path, checkPath));
        final checkReq = await client.getUrl(checkUri).timeout(
              const Duration(seconds: 8),
            );
        // NocoDB usa el header xc-auth (segun el otro proyecto).
        checkReq.headers.set('xc-auth', token);
        checkReq.headers.set('Accept', 'application/json');
        final checkResp = await checkReq.close().timeout(
              const Duration(seconds: 8),
            );

        if (checkResp.statusCode < 200 || checkResp.statusCode >= 300) {
          throw Exception(
            'Proyecto no valido o sin permisos en la API (HTTP ${checkResp.statusCode}).',
          );
        }
      }
    } finally {
      client.close(force: true);
    }
  }
}

// Une paths evitando dobles barras.
String _joinPath(String basePath, String extra) {
  final left = basePath.endsWith('/') ? basePath.substring(0, basePath.length - 1) : basePath;
  final right = extra.startsWith('/') ? extra.substring(1) : extra;
  if (left.isEmpty) {
    return '/$right';
  }
  return '$left/$right';
}
